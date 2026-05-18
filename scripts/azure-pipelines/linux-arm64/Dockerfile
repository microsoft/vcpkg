FROM ubuntu:noble-20260410

ARG BUILD_DATE
ARG POWERSHELL_VERSION=7.6.0
ENV DEBIAN_FRONTEND=noninteractive

RUN <<EOF
set -eux

apt-get update
apt-get install --no-install-recommends -y curl gnupg ca-certificates

UBUNTU_VERSION_ID=$(. /etc/os-release && echo "$VERSION_ID")
curl -L -o packages-microsoft-prod.deb https://packages.microsoft.com/config/ubuntu/${UBUNTU_VERSION_ID}/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm -f packages-microsoft-prod.deb

echo "Build date: ${BUILD_DATE}"
DEBIAN_ARCHITECTURE=$(dpkg --print-architecture)

apt-get update
apt-get upgrade -y
apt-get install --no-install-recommends -y \
    build-essential \
    gcc-13-aarch64-linux-gnu \
    g++-13-aarch64-linux-gnu \
    gfortran-13-aarch64-linux-gnu \
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
        apt-get install --no-install-recommends -y powershell
        ;;
    arm64)
        curl -L -o /tmp/powershell-linux-arm64.tar.gz https://github.com/PowerShell/PowerShell/releases/download/v${POWERSHELL_VERSION}/powershell-${POWERSHELL_VERSION}-linux-arm64.tar.gz
        mkdir -p /opt/microsoft/powershell/7
        tar zxf /tmp/powershell-linux-arm64.tar.gz -C /opt/microsoft/powershell/7
        chmod +x /opt/microsoft/powershell/7/pwsh
        ln -sf /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh
        rm -f /tmp/powershell-linux-arm64.tar.gz
        ;;
    *)
        echo "Unsupported PowerShell architecture: $DEBIAN_ARCHITECTURE" >&2
        exit 1
        ;;
esac

update-alternatives --install /usr/bin/aarch64-linux-gnu-gcc aarch64-linux-gnu-gcc /usr/bin/aarch64-linux-gnu-gcc-13 100
update-alternatives --install /usr/bin/aarch64-linux-gnu-g++ aarch64-linux-gnu-g++ /usr/bin/aarch64-linux-gnu-g++-13 100
update-alternatives --install /usr/bin/aarch64-linux-gnu-gfortran aarch64-linux-gnu-gfortran /usr/bin/aarch64-linux-gnu-gfortran-13 100
rm -rf /var/lib/apt/lists/*
EOF
