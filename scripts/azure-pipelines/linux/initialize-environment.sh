#!/bin/bash
# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

# Cleans up the environment to prevent contamination across builds.
if [ ! -d "archives" ]; then
    ln -s /ci/archives archives
fi
if [ ! -d "installed" ]; then
    ln -s /ci/installed installed
fi

rm -rf installed/*
rm -rf buildtrees
rm -rf packages
