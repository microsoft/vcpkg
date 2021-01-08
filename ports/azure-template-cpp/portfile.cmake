# Copyright (c) Microsoft Corporation. All rights reserved.
# SPDX-License-Identifier: MIT

vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF azure-template_1.0.0-beta.19
    SHA512 B0ADA4A8BE36A7527F3AD6B2D437C11CC0D15A1569533D1F74E32F00236BA8344B413855FA1DB2D3408762B0707A13EBC916E61FB73BEA20CD4EED08F06E89C1
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}/sdk/template/azure-template/
    PREFER_NINJA
    OPTIONS
        -DWARNINGS_AS_ERRORS=OFF
)

vcpkg_install_cmake()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_fixup_cmake_targets()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()

