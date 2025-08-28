# syntax=docker/dockerfile:1
FROM ubuntu:latest AS builder
WORKDIR /src
RUN apt update && apt install -y curl jq p7zip-full cpio
COPY <<EOF ./download-image.sh
query_component() {
    curl -fsSL 'https://ci.openharmony.cn/api/daily_build/build/list/component' \\
        -H 'Accept: application/json, text/plain, */*' \\
        -H 'Content-Type: application/json' \\
        --data-raw '{"projectName":"openharmony","branch":"OpenHarmony-5.1.0-Release","pageNum":1,"pageSize":10,"deviceLevel":"","component":"dayu200-arm64_5.1.0-Release","type":1,"startTime":"2025070100000000","endTime":"20990101235959","sortType":"","sortField":"","hardwareBoard":"","buildStatus":"","buildFailReason":"","withDomain":1}'
}
curl $(query_component | jq -r '.data.list.dataList[0].imgObsPath') -o dayu200-arm64.tar.gz
EOF
RUN sh ./download-image.sh
RUN tar -zxf dayu200-arm64.tar.gz
RUN mkdir system && \
    7z x system.img -osystem
RUN mkdir ramdisk && \
    cp ramdisk.img ramdisk/ramdisk.img.gz && \
    cd ramdisk && \
    gunzip ramdisk.img.gz && \
    cpio -i -F ramdisk.img && \
    rm ramdisk.img && \
    cd .. && \
    cp system/lib64/chipset-pub-sdk/libcrypto_openssl.z.so ramdisk/lib64/ && \
    cp system/lib64/libc++.so ramdisk/lib64/ && \
    cp system/lib64/libc++_shared.so ramdisk/lib64/ && \
    cp -r /etc/ssl ramdisk/etc/ && \
    cp -r ramdisk /tmp/

FROM scratch
COPY --from=builder /tmp/ramdisk /
CMD ["/bin/sh"]

# 创建基本的passwd文件
RUN echo "root:x:0:0:root:/root:/bin/sh" > /etc/passwd && \
    echo "nobody:x:65534:65534:nobody:/nonexistent:/bin/sh" >> /etc/passwd && \
    echo "daemon:x:1:1:daemon:/usr/sbin:/bin/sh" >> /etc/passwd

# 创建group文件
RUN echo "root:x:0:" > /etc/group && \
    echo "nobody:x:65534:" >> /etc/group && \
    echo "daemon:x:1:" >> /etc/group

# 创建必要的目录
RUN mkdir -p /root && chmod 700 /root

# 设置工作目录和用户
WORKDIR /app
USER root
