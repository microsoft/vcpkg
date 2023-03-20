#!/bin/bash
# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#

export DEBIAN_FRONTEND=noninteractive

## PowerShell
wget -q https://packages.microsoft.com/config/ubuntu/20.04/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb
rm -f packages-microsoft-prod.deb
add-apt-repository universe

apt-get -y update
apt-get -y dist-upgrade

## vcpkg prerequisites
APT_PACKAGES="git curl zip unzip tar"

## PowerShell
APT_PACKAGES="$APT_PACKAGES powershell"

## common build dependencies
APT_PACKAGES="$APT_PACKAGES g++ cmake"

apt-get -y --no-install-recommends install $APT_PACKAGES

## Docker
apt-get -y --no-install-recommends install ca-certificates gnupg lsb-release
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get -y --no-install-recommends install docker-ce docker-ce-cli