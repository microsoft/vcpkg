vcpkg_download_distfile(PKGCONFIG_EXPORT_PATCH
    URLS https://github.com/c-ares/c-ares/commit/d41db1b7916fadea987e5bb05fd4aafaf0d1d6ea.patch?full_index=1
    SHA512 a7f96fa0d10f44d0f5981cdeef741fb57228f61bb18a79d581c4f1a8df6ae54771b0fb9f7985a8429dc31c5c3506aa436e8240fdcd4c8503da98a4c7bdce4347
    FILENAME c-ares-pkgconfig-export-d41db1b7916fadea987e5bb05fd4aafaf0d1d6ea.patch
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO c-ares/c-ares
    REF "v${VERSION}"
    SHA512 7bd4ca8f1a1b6d7b6662c724315bb5d4ca1d3c19e5ff4e06e3567ea25d5f8fd60f9c5f9ade055f08dc7fc3dec0e40e96f8284207b3e03c0975fd962d4a9fcb47
    HEAD_REF main
    PATCHES
        avoid-docs.patch
        "${PKGCONFIG_EXPORT_PATCH}"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCARES_STATIC=${BUILD_STATIC}
        -DCARES_SHARED=${BUILD_SHARED}
        -DCARES_BUILD_TOOLS=OFF
        -DCARES_BUILD_TESTS=OFF
        -DCARES_BUILD_CONTAINER_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/c-ares)
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/ares.h"
        "#  ifdef CARES_STATICLIB" "#if 1"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
