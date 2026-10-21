vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO osdp-dev/libosdp
    REF "v${VERSION}"
    SHA512 1035146f7527d405210e908b494e2d7bfc69216515ac59a05c502abf62c32451d13ef76549ca205b291cb3ccfddd42205c3d70b593dd1baf2351019a1732600f
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
    REF "86de31f9b3bf08ffbd1bde3e8cf66614e58a66f4"
    SHA512 e5ffe68d9c7f102bcacd12167aa9c73f3012c2ec194ac6c8aeb4681f8384cf403fdc1ee4f8e4c198ce23acd1510504fa67c76bfb5da26fb0eea3d674d1bf253e
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
