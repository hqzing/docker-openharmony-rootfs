# syntax=docker/dockerfile:1
FROM alpine:3.22 AS builder
WORKDIR /src
RUN apk update && apk add build-base perl linux-headers curl jq 7zip cpio gzip patchelf
COPY build-curl.sh build-curl.sh
RUN ./build-curl.sh
COPY build-rootfs.sh build-rootfs.sh
COPY NOTICE.txt NOTICE.txt
RUN ./build-rootfs.sh

FROM scratch AS final
COPY --from=builder /opt/ramdisk /
CMD ["/bin/sh"]
