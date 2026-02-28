FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    gawk wget git diffstat unzip texinfo gcc \
    build-essential chrpath socat cpio python3 python3-pip \
    python3-pexpect xz-utils debianutils iputils-ping \
    python3-git python3-jinja2 python3-subunit zstd \
    liblz4-tool file locales libacl1 sudo \
    && locale-gen en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install kas --break-system-packages

# Create non-root builder user (avoids root-owned files in mounted volumes)
RUN useradd -m -s /bin/bash builder && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

USER builder
WORKDIR /work

# Usage:
#   docker build -t yocto-builder tools/docker/
#   docker run --rm \
#     -v $(pwd):/work \
#     -v $(pwd)/_yocto-cache:/work/_yocto-cache \
#     yocto-builder \
#     kas build yocto/kas/rpi4.yml
