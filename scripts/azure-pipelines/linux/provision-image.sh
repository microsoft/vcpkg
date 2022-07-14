#!/bin/bash
# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#

export DEBIAN_FRONTEND=noninteractive

apt-get -y update
apt-get -y dist-upgrade

# Install vcpkg prerequisites
APT_PACKAGES="git curl zip unzip tar"

# Install common build dependencies
APT_PACKAGES="$APT_PACKAGES at libxt-dev gperf libxaw7-dev cifs-utils \
  build-essential g++ gfortran libx11-dev libxkbcommon-x11-dev libxi-dev \
  libgl1-mesa-dev libglu1-mesa-dev mesa-common-dev libxinerama-dev libxxf86vm-dev \
  libxcursor-dev yasm libnuma1 libnuma-dev \
  flex libbison-dev autoconf libudev-dev libncurses5-dev libtool libxrandr-dev \
  xutils-dev dh-autoreconf autoconf-archive libgles2-mesa-dev ruby-full \
  pkg-config meson nasm cmake ninja-build"

# CUDA tooling
APT_PACKAGES="$APT_PACKAGES nvidia-cudnn nvidia-cuda-toolkit"

# Additionally required by qt5-base
APT_PACKAGES="$APT_PACKAGES libxext-dev libxfixes-dev libxrender-dev \
  libxcb1-dev libx11-xcb-dev libxcb-glx0-dev libxcb-util0-dev"

# Additionally required by qt5-base for qt5-x11extras
APT_PACKAGES="$APT_PACKAGES libxkbcommon-dev libxcb-keysyms1-dev \
  libxcb-image0-dev libxcb-shm0-dev libxcb-icccm4-dev libxcb-sync-dev \
  libxcb-xfixes0-dev libxcb-shape0-dev libxcb-randr0-dev \
  libxcb-render-util0-dev libxcb-xinerama0-dev libxcb-xkb-dev libxcb-xinput-dev"

# Additionally required by libhdfs3
APT_PACKAGES="$APT_PACKAGES libkrb5-dev"

# Additionally required by kf5windowsystem
APT_PACKAGES="$APT_PACKAGES libxcb-res0-dev"

# Additionally required by mesa
APT_PACKAGES="$APT_PACKAGES python3-setuptools python3-mako"

# Additionally required by some packages to install additional python packages
APT_PACKAGES="$APT_PACKAGES python3-pip python3-venv"

# Additionally required by qtwebengine
APT_PACKAGES="$APT_PACKAGES nodejs"

# Additionally required by qtwayland
APT_PACKAGES="$APT_PACKAGES libwayland-dev"

# Additionally required by all GN projects
APT_PACKAGES="$APT_PACKAGES python2 python-is-python3"

# Additionally required by libctl
APT_PACKAGES="$APT_PACKAGES guile-2.2-dev"

# Additionally required by gtk
APT_PACKAGES="$APT_PACKAGES libxdamage-dev"

# Additionally required by gtk3 and at-spi2-atk
APT_PACKAGES="$APT_PACKAGES libdbus-1-dev"

# Additionally required by at-spi2-atk
APT_PACKAGES="$APT_PACKAGES libxtst-dev"

# Additionally required/installed by Azure DevOps Scale Set Agents
APT_PACKAGES="$APT_PACKAGES libkrb5-3 zlib1g libicu70"

apt-get -y install $APT_PACKAGES

# Install the latest Haskell stack for bond
curl -sSL https://get.haskellstack.org/ | sh

# Start up cudnn
update-nvidia-cudnn -d
update-nvidia-cudnn -u

# Install nccl
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/cuda-ubuntu2204.pin
mv cuda-ubuntu2204.pin /etc/apt/preferences.d/cuda-repository-pin-600
apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/3bf863cc.pub
add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2204/x86_64/ /"
apt-get -y update
apt-get install --no-install-recommends libnccl2 libnccl-dev

# Install PowerShell
wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
apt-get update
add-apt-repository universe
apt-get install -y powershell
