FROM ubuntu:resolute-20260901

ARG BUILD_DATE
ARG POWERSHELL_VERSION=7.6.6
ENV DEBIAN_FRONTEND=noninteractive

RUN <<EOF
set -eux

apt-get update
apt-get install --no-install-recommends -y curl ca-certificates

echo "Build date: ${BUILD_DATE}"
DEBIAN_ARCHITECTURE=$(dpkg --print-architecture)

apt-get update
apt-get upgrade -y
apt-get install --no-install-recommends -y \
    build-essential \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    gfortran-aarch64-linux-gnu \
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
    libicu78 \
    libudev-dev \
    libtirpc-dev \
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
    python3-venv \
    gnupg \
    tar \
    python3-pip

case "$DEBIAN_ARCHITECTURE" in
    amd64)
        POWERSHELL_ARCHITECTURE=x64
        ;;
    arm64)
        POWERSHELL_ARCHITECTURE=arm64
        ;;
    *)
        echo "Unsupported PowerShell architecture: $DEBIAN_ARCHITECTURE" >&2
        exit 1
        ;;
esac

curl -L -o /tmp/powershell.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell-${POWERSHELL_VERSION}-linux-${POWERSHELL_ARCHITECTURE}.tar.gz
mkdir -p /opt/microsoft/powershell/7
tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7
chmod +x /opt/microsoft/powershell/7/pwsh
ln -sf /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh
rm -f /tmp/powershell.tar.gz

rm -rf /var/lib/apt/lists/*
EOF
