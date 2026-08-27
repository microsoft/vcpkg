vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osdp-dev/libosdp
    REF "v${VERSION}"
    SHA512 6994d6d54d237d6783a9ad4bdd2f60afedcbcef2bf89b498101aa121b1aeea4108d35da639ced853c0c4bce2782a533ad00215706fa42822e7ea8acf023c65b9
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
    REF "33c08a2bf9ff7fb295677c28174180dec690270a"
    SHA512 27c5841525d043983bffd1f8ca642dff649d98759db191a224662d149fa1d316518e0043b602177e07519720152896cbb7f15a82b37f3e8390caf4f5a73b6dc9
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
