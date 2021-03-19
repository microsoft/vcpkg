# Copyright (c) Microsoft Corporation. All rights reserved.
# SPDX-License-Identifier: MIT

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF azure-storage-files-datalake_12.0.0-beta.8
    SHA512 e5c767da318e5d709627c7fd0b72bf3ff401c0bb56a1476347d927100ee7724aac0472ccb5c9185fa1761bfb894ee8a5d48e0bea5987cbde376cba94250ca1ca
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/sdk/storage/azure-storage-files-datalake/
    PREFER_NINJA
    OPTIONS
        -DWARNINGS_AS_ERRORS=OFF
)

vcpkg_install_cmake()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_fixup_cmake_targets()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()

