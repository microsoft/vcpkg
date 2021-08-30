# Copyright (c) Microsoft Corporation. All rights reserved.
# SPDX-License-Identifier: MIT
# Added change to validate multiple releases to the same PR

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Azure/azure-sdk-for-cpp
    REF azure-template_1.0.0-beta.1073058
    SHA512 60beb42b3aeb4cbd3205ded12fb3e54a7d903d508de5d3e2f68f2e6e775348cc0c7f932ed22618f34c4ddd58be22b2d442a538c742ab94527566897018032117
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}/sdk/template/azure-template/
    OPTIONS
        -DWARNINGS_AS_ERRORS=OFF
)

vcpkg_cmake_install()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_cmake_config_fixup()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
vcpkg_copy_pdbs()
