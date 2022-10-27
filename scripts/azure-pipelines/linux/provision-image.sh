#!/bin/bash
# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#

export DEBIAN_FRONTEND=noninteractive

# Add apt repos

## CUDA
apt-key del 7fa2af80
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin
mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600
apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub
add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /"

## PowerShell
wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm -f packages-microsoft-prod.deb
add-apt-repository universe

apt-get -y update
apt-get -y dist-upgrade

# Add apt packages

## vcpkg prerequisites
APT_PACKAGES="git curl zip unzip tar"

## common build dependencies
APT_PACKAGES="$APT_PACKAGES at gperf cifs-utils \
  build-essential g++ gfortran yasm libtool-bin \
  flex bison libbison-dev autoconf libudev-dev libtool \
  dh-autoreconf autoconf-archive ruby-full \
  pkg-config meson nasm cmake ninja-build"

# Questions:
# Why/Where to get libbison-dev ?
# Where to get libudev-dev ?
# Why/Where to get libncurses5-dev ?

## required by libhdfs3
APT_PACKAGES="$APT_PACKAGES libkrb5-dev"

## required by mesa
APT_PACKAGES="$APT_PACKAGES python3-setuptools python3-mako"

## required by some packages to install additional python packages
APT_PACKAGES="$APT_PACKAGES python3-pip python3-venv"

## required by qtwebengine
APT_PACKAGES="$APT_PACKAGES nodejs"

## required by all GN projects
APT_PACKAGES="$APT_PACKAGES python2 python-is-python3"

## required by libctl
APT_PACKAGES="$APT_PACKAGES guile-2.2-dev"

## required by bond
APT_PACKAGES="$APT_PACKAGES haskell-stack"

## required by duktape
APT_PACKAGES="$APT_PACKAGES python-yaml"

## CUDA
APT_PACKAGES="$APT_PACKAGES cuda-compiler-11-6 cuda-libraries-dev-11-6 cuda-driver-dev-11-6 \
  cuda-cudart-dev-11-6 libcublas-11-6 libcurand-dev-11-6 cuda-nvml-dev-11-6 libcudnn8-dev libnccl2 \
  libnccl-dev"

## PowerShell
APT_PACKAGES="$APT_PACKAGES powershell"

## Additionally required/installed by Azure DevOps Scale Set Agents, skip on WSL
if [[ $(grep microsoft /proc/version) ]]; then
echo "Skipping install of ADO prerequisites on WSL."
else
APT_PACKAGES="$APT_PACKAGES libkrb5-3 zlib1g libicu66"
fi

apt-get -y --no-install-recommends install $APT_PACKAGES
