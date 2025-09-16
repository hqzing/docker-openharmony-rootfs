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
docker run -itd --name=ohos ghcr.io/hqzing/docker-openharmony-rootfs:latest
docker exec -it ohos sh
```

## Need more tools?
The rootfs of OpenHarmony is mainly composed of three parts: [musl libc](https://musl.libc.org/), [toybox](https://landley.net/toybox), and [mksh](https://github.com/MirBSD/mksh).

In this rootfs, the command-line tools are provided by `toybox`, which offers a very limited number of tools.

Additionally, since OpenHarmony has not yet provided a package manager, we can't conveniently install new software through one.

All I can do is pre-install `curl` in the image so you can use it to download other software yourself.

Many software for the arm64-linux-musl platform can run in this container, such as `busybox` here.
```sh
cd /tmp
curl -L -O https://dl-cdn.alpinelinux.org/v3.22/main/aarch64/busybox-static-1.37.0-r19.apk
tar -zxf busybox-static-1.37.0-r19.apk
cp ./bin/busybox.static /bin/busybox
ln -s /bin/busybox /bin/vi
ln -s /bin/busybox /bin/wget
# now you can use 'vi' and 'wget' command
```

Or you can find additional software that has been ported to OpenHarmony through [this community](https://gitcode.com/OpenHarmonyPCDeveloper).

## Use in GitHub workflow

To use this image in GitHub workflow, you first need to use an arm64 runner.

GitHub provides arm64 [partner runner images](https://github.com/actions/partner-runner-images) that we can use for free.

It should be noted that there is a very commonly used workflow called `actions/checkout`, which depends on the Node.js environment, and we need to give it special treatment.

```yml
jobs:
  buid:
    name: build
    runs-on: ubuntu-24.04-arm
    container:
      image: ghcr.io/hqzing/docker-openharmony-rootfs:latest
      volumes:
        - /tmp/node20-ohos:/__e/node20:rw,rshared
    steps:
      - name: Setup node for actions/checkout
        run: |
          curl -L -O https://github.com/hqzing/build-ohos-node/releases/download/v24.2.0/node-v24.2.0-openharmony-arm64.tar.gz
          mkdir -p /opt /__e/node20/bin
          tar -zxf node-v24.2.0-openharmony-arm64.tar.gz -C /opt
          ln -s /opt/node-v24.2.0-openharmony-arm64/bin/node /__e/node20/bin/node
      - name: Chekout
        uses: actions/checkout@v4
      # Do your work...
```

This solution refers to https://github.com/actions/runner/issues/801.
