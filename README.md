# Docker-openharmony-rootfs
Because the userland of OpenHarmony can run on the Linux kernel, containerization of OpenHarmony is feasible.

This project has turned OpenHarmony's mini rootfs into a Docker image, which allows us to use Linux servers instead of physical OpenHarmony devices to run and test our command-line programs.

## Architecture support
arm64 only

## Get image
Pull from GitHub Container Registry
```sh
docker pull ghcr.io/hqzing/docker-openharmony-rootfs:latest

# chinese mirror site
# docker pull ghcr.nju.edu.cn/hqzing/docker-openharmony-rootfs:latest
```

Or build image yourself
```sh
git clone https://github.com/hqzing/docker-openharmony-rootfs
cd docker-openharmony-rootfs
docker build -t docker-openharmony-rootfs:latest .
```

## Usage
Run the container with default command
```sh
docker rm -f ohos
docker run -itd --name=ohos ghcr.io/hqzing/docker-openharmony-rootfs:latest
docker exec -it ohos sh
```

## Need more command-line tools?
The rootfs of OpenHarmony is mainly composed of three parts: [musl libc](https://musl.libc.org/), [toybox](https://landley.net/toybox), and [mksh](https://github.com/MirBSD/mksh).

In this rootfs, the command-line tools are provided by `toybox`, which offers a very limited number of command-line tools. For example, it currently lacks tools such as `vi` and `wget`.

Additionally, OpenHarmony has not yet provided a package manager. It's difficult for us to increase command-line tools. 

To temporarily meet the basic needs, I offer a third-party solution: We can download a statically linked `busybox` and place it into the container for use.

```sh
wget https://dl-cdn.alpinelinux.org/v3.22/main/aarch64/busybox-static-1.37.0-r18.apk
tar -zxf busybox-static-1.37.0-r18.apk

docker run -itd --name=ohos ghcr.io/hqzing/docker-openharmony-rootfs:latest
docker cp ./bin/busybox.static ohos:/bin/busybox

docker exec -t ohos ln -s /bin/busybox /bin/vi
docker exec -t ohos ln -s /bin/busybox /bin/wget
```

Now we can use `vi` and `wget` in the container

```sh
docker exec -it ohos sh

vi --help
wget --help
```
