vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osdp-dev/libosdp
    REF "v${VERSION}"
    SHA512 a73315ff8a7290176239235046b4315de11f324036d008cfcc44af9e88baa1e9eaeb41731fa167a690b67c639b35688ea3cf3e5e7af1edf813d13a179eeb05a7
    HEAD_REF master
    PATCHES
        fix-export-macros.patch
)

# Download and extract the c-utils submodule at ${SOURCE_PATH}/utils as
# it would be during a recursive checkout.
#
# Note: During package upgrade, the submodule ref needs to be updated.
vcpkg_from_github(
    OUT_SOURCE_PATH UTILS_SOURCE_PATH
    REPO osdp-dev/c-utils
    REF de5fd0b21af0fb1c8327b99cda7f2aec754be761
    SHA512 4710cc6232eb75e35441898573fdbe0388d2d7fa39730ae0238744b346a4557cd86f0f157aea3ec5d4befcc75633a3100ffc7c8ba3470cc747d540c770ab6c7b
    HEAD_REF master
)

file(REMOVE_RECURSE "${SOURCE_PATH}/utils")
file(COPY "${UTILS_SOURCE_PATH}/" DESTINATION "${SOURCE_PATH}/utils")

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)

# Main commands
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOPT_OSDP_LIB_ONLY=ON
        -DOPT_BUILD_SHARED=${BUILD_SHARED}
        -DOPT_BUILD_STATIC=${BUILD_STATIC}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libosdp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(BUILD_STATIC)
    # Bake the define OSDP_STATIC_DEFINE into the installed header to ensure consumers get it.
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libosdp/osdp_export.h"
        "#define _OSDP_EXPORT_H_"
        "#define _OSDP_EXPORT_H_\n\n#define OSDP_STATIC_DEFINE"
    )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
