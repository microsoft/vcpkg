# Copyright (c) Microsoft Corporation. All rights reserved.
# SPDX-License-Identifier: MIT

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO antkmsft/azure-sdk-for-cpp
    REF azure-sdk-for-cpp_1.0.0-beta.2
    SHA512 465777618b36f405c74446216149162f28a9de579b7f43545eae4d1657388d561f2b849aa2644a2ae785f5fd1f01177cb0ead311faae9f1806dc2c7e7f4dc872
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/sdk/storage/azure-storage-blobs/
    PREFER_NINJA
    OPTIONS
        -DWARNINGS_AS_ERRORS=OFF
)

vcpkg_install_cmake()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_fixup_cmake_targets()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()
