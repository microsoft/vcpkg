#!/bin/bash
# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#

sudo apt -y update
sudo apt -y dist-upgrade
# Install common build dependencies
APT_PACKAGES="at curl unzip tar libxt-dev gperf libxaw7-dev cifs-utils \
  build-essential g++ gfortran zip libx11-dev libxkbcommon-x11-dev libxi-dev \
  libgl1-mesa-dev libglu1-mesa-dev mesa-common-dev libxinerama-dev libxxf86vm-dev \
  libxcursor-dev yasm libnuma1 libnuma-dev python-six python3-six python-yaml \
  flex libbison-dev autoconf libudev-dev libncurses5-dev libtool libxrandr-dev \
  xutils-dev dh-autoreconf autoconf-archive libgles2-mesa-dev ruby-full \
  pkg-config meson"

# Additionally required by qt5-base
APT_PACKAGES="$APT_PACKAGES libxext-dev libxfixes-dev libxrender-dev \
  libxcb1-dev libx11-xcb-dev libxcb-glx0-dev libxcb-util0-dev"

# Additionally required by qt5-base for qt5-x11extras
APT_PACKAGES="$APT_PACKAGES libxkbcommon-dev libxcb-keysyms1-dev \
  libxcb-image0-dev libxcb-shm0-dev libxcb-icccm4-dev libxcb-sync0-dev \
  libxcb-xfixes0-dev libxcb-shape0-dev libxcb-randr0-dev \
  libxcb-render-util0-dev libxcb-xinerama0-dev libxcb-xkb-dev libxcb-xinput-dev"

# Additionally required by libhdfs3
APT_PACKAGES="$APT_PACKAGES libkrb5-dev"

# Additionally required by kf5windowsystem
APT_PACKAGES="$APT_PACKAGES libxcb-res0-dev"

# Additionally required by mesa
APT_PACKAGES="$APT_PACKAGES python3-setuptools python3-mako"

# Additionally required by some packages to install additional python packages
APT_PACKAGES="$APT_PACKAGES python3-pip"

# Additionally required by rtaudio
APT_PACKAGES="$APT_PACKAGES libasound2-dev"

# Additionally required by qtwebengine
APT_PACKAGES="$APT_PACKAGES nodejs"

# Additionally required by qtwayland
APT_PACKAGES="$APT_PACKAGES libwayland-dev"

# Additionally required by all GN projects
APT_PACKAGES="$APT_PACKAGES python2 python-is-python3"

# Additionally required/installed by Azure DevOps Scale Set Agents
APT_PACKAGES="$APT_PACKAGES liblttng-ust0 libkrb5-3 zlib1g libicu66"

sudo apt -y install $APT_PACKAGES

# Install newer version of nasm than the apt package, required by intel-ipsec
mkdir /tmp/nasm
cd /tmp/nasm
curl -O https://www.nasm.us/pub/nasm/releasebuilds/2.15.05/nasm-2.15.05.tar.gz
tar -xf nasm-2.15.05.tar.gz
cd nasm-2.15.05/
./configure --prefix=/usr && make -j
sudo make install
cd ~

# Install the latest Haskell stack
curl -sSL https://get.haskellstack.org/ | sudo sh

# Install CUDA
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
sudo mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
sudo apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/7fa2af80.pub
sudo add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"
sudo apt -y update
sudo apt install -y --no-install-recommends cuda-compiler-11-3 cuda-libraries-dev-11-3 cuda-driver-dev-11-3 \
  cuda-cudart-dev-11-3 libcublas-11-3 libcurand-dev-11-3 libcudnn8-dev libnccl2 libnccl-dev

# Install PowerShell
wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo add-apt-repository universe
sudo apt install -y powershell
