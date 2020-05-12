#!/bin/bash
# Copyright (c) Microsoft Corporation.
# SPDX-License-Identifier: MIT

# Cleans up the environment to prevent contamination across builds.
if [ ! -d "archives" ]; then
    ln -s /archives archives
fi

rm -rf installed
rm -rf buildtrees
rm -rf packages/*
