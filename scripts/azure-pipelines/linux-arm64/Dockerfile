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
        libxinerama-dev \
        libglu1-mesa-dev \
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
