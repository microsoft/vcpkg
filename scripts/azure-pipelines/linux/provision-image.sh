#!/bin/bash
# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#

sudo apt -y update
sudo apt -y dist-upgrade
# Install common build dependencies and partitioning tools
sudo apt -y install at curl unzip tar libxt-dev gperf libxaw7-dev cifs-utils build-essential g++ zip libx11-dev libxi-dev libgl1-mesa-dev libglu1-mesa-dev mesa-common-dev libxinerama-dev libxcursor-dev yasm libnuma1 libnuma-dev python-six python3-six python-yaml flex libbison-dev autoconf libudev-dev libncurses5-dev libtool libxrandr-dev xutils-dev dh-autoreconf libgles2-mesa-dev ruby-full pkg-config
# Required by qt5-x11extras
sudo apt -y install libxkbcommon-dev libxkbcommon-x11-dev
# Required by libhdfs3
sudo apt -y install libkrb5-dev

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
sudo ln -s /usr/local/cuda-10.1/lib64/stubs/libcuda.so /usr/local/cuda-10.1/lib64/stubs/libcuda.so.1

# Install PowerShell
wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo apt update
sudo add-apt-repository universe
sudo apt install -y powershell

# Write SMB credentials
sudo mkdir /etc/smbcredentials
smbCredentialFile=/etc/smbcredentials/$StorageAccountName.cred
echo "username=$StorageAccountName" | sudo tee $smbCredentialFile > /dev/null
echo "password=$StorageAccountKey" | sudo tee -a $smbCredentialFile > /dev/null
sudo chmod 600 $smbCredentialFile

# Write script to provision disks used by cloud-init
echo "if [ ! -d \"/ci\" ]; then" > /etc/provision-disks.sh
echo "sudo parted /dev/sdc mklabel gpt" >> /etc/provision-disks.sh
echo "sudo parted /dev/sdc mkpart cidisk ext4 0% 100%" >> /etc/provision-disks.sh
echo "sudo mkfs -t ext4 /dev/sdc1" >> /etc/provision-disks.sh
echo "sudo mkdir /ci -m=777" >> /etc/provision-disks.sh
echo "sudo mkdir /ci/installed -m=777" >> /etc/provision-disks.sh
echo "sudo mkdir /ci/archives -m=777" >> /etc/provision-disks.sh
echo "echo \"/dev/sdc1 /ci/installed ext4 barrier=0 0 0\" | sudo tee -a /etc/fstab" >> /etc/provision-disks.sh
echo "echo \"//$StorageAccountName.file.core.windows.net/archives /ci/archives cifs nofail,vers=3.0,credentials=$smbCredentialFile,serverino,dir_mode=0777,file_mode=0777 0 0\" | sudo tee -a /etc/fstab" >> /etc/provision-disks.sh
echo "sudo mount -a" >> /etc/provision-disks.sh
echo "fi" >> /etc/provision-disks.sh
sudo chmod 700 /etc/provision-disks.sh

# Delete /etc/debian_version to prevent Azure Pipelines Scale Set Agents from removing some of the above
sudo rm /etc/debian_version

# Install dependencies that the Azure Pipelines agent will want later to make launching VMs faster
# https://docs.microsoft.com/en-us/dotnet/core/install/dependencies?tabs=netcore31&pivots=os-linux
# (we assume libssl1.0.0 or equivalent is already installed to not accidentially change SSL certs)
apt install -y liblttng-ust0 libkrb5-3 zlib1g libicu60
