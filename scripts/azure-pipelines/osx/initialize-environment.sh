#!/bin/bash
# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

# Sets up the environment for MacOS runs of vcpkg CI

#delete downloaded files that have not been used in 7 days
find ~/Data/downloads/  -maxdepth 1 -type f ! -atime 7  -exec rm -f {} \;
