# Copyright (c) Microsoft Corporation. All rights reserved.
# SPDX-License-Identifier: MIT

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF azure-storage-common_12.0.0-beta.8
    SHA512 8630ab3bbc7e39bfae4c24fdf343c9e7fb076069757a308698593d935b6d1e23dac5f0d8fb68c16751735b2e6d7b825adc39594e4f3b09cdfc35d0a6c6506f50
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/sdk/storage/azure-storage-common/
    PREFER_NINJA
    OPTIONS
        -DWARNINGS_AS_ERRORS=OFF
)

vcpkg_install_cmake()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_fixup_cmake_targets()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()

