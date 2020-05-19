#!/bin/bash
# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

# Sets up the environment for MacOS runs of vcpkg CI

mkdir -p ~/Data/installed || true
ln -s ~/Data/installed

mkdir -p ~/Data/buildtrees || true
ln -s ~/Data/buildtrees

mkdir -p ~/Data/packages || true
ln -s ~/Data/packages

rm archives || rm -rf archives || true
ln -s ~/Data/archives

mkdir -p ~/Data/downloads || true
ln -s ~/Data/downloads

#delete downloaded files that have not been used in 7 days
find downloads/  -maxdepth 1 -type f ! -atime 7  -exec rm -f {} \;
