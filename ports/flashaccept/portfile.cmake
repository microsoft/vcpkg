vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO thealonlevi/flashaccept
    REF "v${VERSION}"
    SHA512 048a0dfdaf97657c7572820d48da6cb3d62edd22d9826e3e81974fd4bb662c614c357f6591592209dff6dfdc6c47927106d075361a02be28fdf98804f48afc15
    HEAD_REF main
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" FA_SHARED)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static"  FA_STATIC)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DFLASHACCEPT_BUILD_EXAMPLES=OFF
        -DFLASHACCEPT_BUILD_SHARED=${FA_SHARED}
        -DFLASHACCEPT_BUILD_STATIC=${FA_STATIC}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME flashaccept CONFIG_PATH lib/cmake/flashaccept)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
