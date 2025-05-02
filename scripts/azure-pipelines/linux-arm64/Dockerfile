FROM ubuntu:jammy-20250404

ARG BUILD_DATE
ENV DEBIAN_FRONTEND=noninteractive

RUN echo "Build date: ${BUILD_DATE}" && \
    apt-get update && \
    apt-get upgrade -y && \
    apt-get install --no-install-recommends -y \
    build-essential \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    cmake \
    ninja-build \
    curl \
    unzip \
    git \
    pkg-config \
    zip \
    python3 \
    python3-pip \
    gnupg \
    ca-certificates \
&& rm -rrf /var/lib/apt/lists/*
