FROM ubuntu:jammy-20250404

ARG BUILD_DATE
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install --no-install-recommends -y curl gnupg ca-certificates && \
    curl -L -o packages-microsoft-prod.deb https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm -f packages-microsoft-prod.deb

RUN echo "Build date: ${BUILD_DATE}" && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        powershell \
        build-essential \
        gcc-aarch64-linux-gnu \
        g++-aarch64-linux-gnu \
        cmake \
        autoconf \
        autoconf-archive \
        automake \
        autopoint \
        libtool \
        libtool-bin \
        libltdl-dev \
        m4 \
        gfortran \
        libnuma1 \
        libnuma-dev \
        libudev-dev \
        libx11-dev \
        libxcursor-dev \
        libxtst-dev \
        libxi-dev \
        libxrandr-dev \
        libxxf86vm-dev \
        libxext-dev \
        libxfixes-dev \
        libxrender-dev \
        libxcb1-dev \
        libx11-xcb-dev \
        libxcb-glx0-dev \
        libxcb-util0-dev \
        libxkbcommon-dev \
        libxcb-keysyms1-dev \
        libxcb-image0-dev \
        libxcb-shm0-dev \
        libxcb-icccm4-dev \
        libxcb-sync-dev \
        libxcb-xfixes0-dev \
        libxcb-shape0-dev \
        libxcb-randr0-dev \
        libxcb-render-util0-dev \
        libxcb-xinerama0-dev \
        libxcb-xkb-dev \
        libxcb-xinput-dev \
        libxcb-cursor-dev \
        libxkbcommon-x11-dev \
        libxinerama-dev \
        libglu1-mesa-dev \
        libgl1-mesa-dev \
        libgl-dev \
        libxmu-dev \
        xorg-dev \
        mesa-common-dev \
        gettext \
        ninja-build \
        unzip \
        git \
        pkg-config \
        bison \
        flex \
        nasm \
        yasm \
        gperf \
        zip \
        python3 \
        python3-setuptools \
        gnupg \
        python3-pip && \
    rm -rf /var/lib/apt/lists/*
