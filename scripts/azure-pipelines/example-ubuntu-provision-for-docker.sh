#!/bin/bash
# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT
#
# This script is to set up the machine for the Docker host.

# This script is no longer used by official vcpkg testing due to an internal compliance effort
# requiring use of CBL-Mariner. It's still intended to be more or less identical to how the lab
# actually works though; everything meaningful is inside the Docker image; see Dockerfile

export DEBIAN_FRONTEND=noninteractive

## Docker
apt-get -y --no-install-recommends install ca-certificates gnupg lsb-release
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get -y --no-install-recommends install docker-ce docker-ce-cli
