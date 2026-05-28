vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO strukturag/libde265
    REF "v${VERSION}"
    SHA512 72e7ea2f145784e8429f4338337e759d23c194e90d08264b71c0e7b2864201c58c5e78bcb0d950d94bdd68ec84af8e37342ed2fd743f48535283afae0e6930ea
    HEAD_REF master
    PATCHES
        fix-linkage.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DENABLE_SDL=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libde265)
vcpkg_copy_tools(TOOL_NAMES dec265 AUTO_CLEAN)
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libde265/de265.h" "!defined(LIBDE265_STATIC_BUILD)" "0")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libde265/de265.h" "!defined(LIBDE265_STATIC_BUILD)" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
