#!/bin/bash
# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

# Sets up the environment for MacOS runs of vcpkg CI

rm -rf installed || true
mkdir -p ~/Data/installed || true
ln -s ~/Data/installed
rm -rf ~/Data/installed/* || true

rm -rf buildtrees || true
mkdir -p ~/Data/buildtrees || true
ln -s ~/Data/buildtrees
rm -rf ~/Data/buildtrees/* || true

rm -rf packages || true
mkdir -p ~/Data/packages || true
ln -s ~/Data/packages
rm -rf ~/Data/packages/* || true

rm archives || rm -rf archives || true
ln -s ~/Data/archives

rm -rf downloads || true
mkdir -p ~/Data/downloads || true
ln -s ~/Data/downloads

if [ -d downloads/ ]; then
#delete downloaded files that have not been used in 7 days
find downloads/  -maxdepth 1 -type f ! -atime 7  -exec rm -f {} \;
fi
