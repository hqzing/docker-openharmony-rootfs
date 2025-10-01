# docker-openharmony-rootfs
Because the userland of OpenHarmony can run on the Linux kernel, containerization of OpenHarmony is feasible.

This project has turned OpenHarmony's mini rootfs into a Docker container image, which allows us to use Linux servers instead of physical OpenHarmony devices to run and test our command-line programs.

## Supported architectures
arm64 only

## Usage
Pull from GitHub Container Registry
```sh
docker pull ghcr.io/hqzing/docker-openharmony-rootfs:latest

# Chinese mirror site
# docker pull ghcr.nju.edu.cn/hqzing/docker-openharmony-rootfs:latest
```

Run the container with default command
```sh
docker run -itd --name=ohos ghcr.io/hqzing/docker-openharmony-rootfs:latest
docker exec -it ohos sh
```

## Need more software?
The OpenHarmony root filesystem (rootfs) is composed of three main components: [musl libc](https://musl.libc.org), [toybox](https://landley.net/toybox), and [mksh](https://github.com/MirBSD/mksh). Command-line utilities are provided by `toybox`, which offers only a minimal set of tools.

Since OpenHarmony currently does not include a package manager, additional software cannot be installed using a single command.

For convenience, `curl` is pre-installed in the container image, allowing users to download additional software manually.

A lot of software compiled for the linux-musl-arm64 platform can run in this container. For example, `make` from the Alpine Linux package repository is compatible:

```sh
package_name="make"
alpine_repository="http://dl-cdn.alpinelinux.org/alpine/v3.22/main/aarch64"
curl -fsSL ${alpine_repository}/APKINDEX.tar.gz | tar -zx -C /tmp/
package_version=$(grep -A1 "^P:${package_name}$" /tmp/APKINDEX | sed -n "s/^V://p")
apk_file_name=${package_name}-${package_version}.apk
curl -L -O ${alpine_repository}/${apk_file_name}
tar -zxf ${apk_file_name} -C /

# You can now use the 'make' command.
```

You can also explore software that has already been ported to OpenHarmony via [this community repository](https://gitcode.com/OpenHarmonyPCDeveloper).

## Use in GitHub workflow

To use this image in GitHub workflow, you first need to use an arm64 runner. GitHub provides arm64 [partner runner images](https://github.com/actions/partner-runner-images) that we can use for free.

It should be noted that many preconfigured workflows on GitHub (such as actions/checkout) depend on the Node.js runtime environment. We need to make some special preparations for them.

```yml
jobs:
  buid:
    name: build
    runs-on: ubuntu-24.04-arm
    container:
      image: ghcr.io/hqzing/docker-openharmony-rootfs:latest
      volumes:
        - /tmp/node20:/__e/node20:rw,rshared
    steps:
      - name: Setup node for actions
        run: |
          curl -L -O https://github.com/hqzing/build-ohos-node/releases/download/v24.2.0/node-v24.2.0-openharmony-arm64.tar.gz
          mkdir /__e/node20/bin
          tar -zxf node-v24.2.0-openharmony-arm64.tar.gz -C /opt
          ln -s /opt/node-v24.2.0-openharmony-arm64/bin/node /__e/node20/bin/node
      - name: Chekout
        uses: actions/checkout@v4
      # Do your work...
```

This solution refers to https://github.com/actions/runner/issues/801.

A practical case of using this container in the workflow: https://github.com/hqzing/build-ohos-perl

## Build image from source

Environment Requirements:
- Ubuntu 22.04 x64 (24.04 is not supported)
- At least 200GB of available disk space
- Docker installed on the build machine
- A network environment that allows seamless access to GitHub, Gitee, etc
- Use the root user (OpenHarmony's build.sh requires root, so this project does too)

Recommendations:
- It is recommended that you reset your build machine before building, and use a clean and brand-new build machine for the build. This avoids many build failures caused by environment issues.
- It is recommended to use high bandwidth and a powerful CPU, as building an operating system involves downloading and compiling many files.

The commands to build the container image are as follows:
```sh
git clone https://github.com/hqzing/docker-openharmony-rootfs
cd docker-openharmony-rootfs
./build-images.sh
./build-rootfs.sh
DOCKER_BUILDKIT=1 docker buildx build --platform linux/arm64 -t docker-openharmony-rootfs:latest .
```

Since the build machine is x64-based while the container is arm64-based, you cannot run the container directly on the build machine. Instead, you must export or publish it and then deploy it on an arm64 server.
