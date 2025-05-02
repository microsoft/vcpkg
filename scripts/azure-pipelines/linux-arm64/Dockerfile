FROM ubuntu:jammy-20250404

ARG BUILD_DATE
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install --no-install-recommends -y curl gnupg ca-certificates && \
    curl -L -o packages-microsoft-prod.deb https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb && \
    rm -f packages-microsoft-prod.deb

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
        powershell \
        build-essential \
        gcc-aarch64-linux-gnu \
        g++-aarch64-linux-gnu \
        cmake \
        ninja-build \
        unzip \
        git \
        pkg-config \
        zip \
        python3 \
        python3-pip && \
    rm -rf /var/lib/apt/lists/*