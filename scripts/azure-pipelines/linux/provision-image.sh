#!/bin/bash
# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#

sudo apt -y update
sudo apt -y dist-upgrade
# Install common build dependencies
APT_PACKAGES="at curl unzip tar libxt-dev gperf libxaw7-dev cifs-utils \
  build-essential g++ gfortran zip libx11-dev libxkbcommon-x11-dev libxi-dev \
  libgl1-mesa-dev libglu1-mesa-dev mesa-common-dev libxinerama-dev \
  libxcursor-dev yasm libnuma1 libnuma-dev python-six python3-six python-yaml \
  flex libbison-dev autoconf libudev-dev libncurses5-dev libtool libxrandr-dev \
  xutils-dev dh-autoreconf libgles2-mesa-dev ruby-full pkg-config"

# Additionally required by qt5-base
APT_PACKAGES="$APT_PACKAGES libxext-dev libxfixes-dev libxrender-dev \
  libxcb1-dev libx11-xcb-dev libxcb-glx0-dev"

# Additionally required by qt5-base for qt5-x11extras
APT_PACKAGES="$APT_PACKAGES libxkbcommon-dev libxcb-keysyms1-dev \
  libxcb-image0-dev libxcb-shm0-dev libxcb-icccm4-dev libxcb-sync0-dev \
  libxcb-xfixes0-dev libxcb-shape0-dev libxcb-randr0-dev \
  libxcb-render-util0-dev libxcb-xinerama0-dev libxcb-xkb-dev libxcb-xinput-dev"

# Additionally required by libhdfs3
APT_PACKAGES="$APT_PACKAGES libkrb5-dev"

# Additionally required by mesa
APT_PACKAGES="$APT_PACKAGES python3-setuptools python3-mako"

# Additionally required by some packages to install additional python packages
APT_PACKAGES="$APT_PACKAGES python3-pip"

# Additionally required/installed by Azure DevOps Scale Set Agents
APT_PACKAGES="$APT_PACKAGES liblttng-ust0 libkrb5-3 zlib1g libicu60"

sudo apt -y install $APT_PACKAGES

# Delete /etc/debian_version to prevent Azure Pipelines Scale Set Agents from
# removing some of the above
sudo apt-mark hold libcurl4
sudo apt-mark hold liblttng-ust0
sudo apt-mark hold libkrb5-3
sudo apt-mark hold zlib1g
sudo apt-mark hold libicu60

# Install newer version of nasm than the apt package, required by intel-ipsec
mkdir /tmp/nasm
cd /tmp/nasm
curl -O https://www.nasm.us/pub/nasm/releasebuilds/2.14.02/nasm-2.14.02.tar.gz
tar -xf nasm-2.14.02.tar.gz
cd nasm-2.14.02/
./configure --prefix=/usr && make -j
sudo make install
cd ~

# Install the latest Haskell stack
curl -sSL https://get.haskellstack.org/ | sudo sh

# Install CUDA
wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-repo-ubuntu1804_10.2.89-1_amd64.deb
sudo apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/7fa2af80.pub
sudo dpkg -i cuda-repo-ubuntu1804_10.2.89-1_amd64.deb
wget http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/nvidia-machine-learning-repo-ubuntu1804_1.0.0-1_amd64.deb
sudo dpkg -i nvidia-machine-learning-repo-ubuntu1804_1.0.0-1_amd64.deb
sudo apt -y update
sudo apt install -y --no-install-recommends cuda-compiler-10-2 cuda-libraries-dev-10-2 cuda-driver-dev-10-2 cuda-cudart-dev-10-2 libcublas10 cuda-curand-dev-10-2
sudo apt install -y --no-install-recommends libcudnn7-dev

# Install PowerShell
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo add-apt-repository universe
sudo apt install -y powershell

if [ -z "$StorageAccountName" ]; then
echo "No storage account supplied, skipping."
else
echo "Mapping storage account"

# Write SMB credentials
sudo mkdir /etc/smbcredentials
smbCredentialFile=/etc/smbcredentials/$StorageAccountName.cred
echo "username=$StorageAccountName" | sudo tee $smbCredentialFile > /dev/null
echo "password=$StorageAccountKey" | sudo tee -a $smbCredentialFile > /dev/null
sudo chmod 600 $smbCredentialFile

# Mount the archives SMB share to /archives
sudo mkdir /archives -m=777
echo "//$StorageAccountName.file.core.windows.net/archives /archives cifs nofail,vers=3.0,credentials=$smbCredentialFile,serverino,dir_mode=0777,file_mode=0777 0 0" | sudo tee -a /etc/fstab
fi
