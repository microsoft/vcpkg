# Copyright (c) Microsoft Corporation. All rights reserved.
# SPDX-License-Identifier: MIT

vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF azure-template_1.0.0-beta.23
    SHA512 0dcc49858e7b60eefb4164707aea7eb7b30792c2279efee5f214eedaf0dba4ad682b80ff3692c96069e864bb06748ac38cd773dffe55d9166688a1da66a214ba
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

