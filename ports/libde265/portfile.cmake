vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO strukturag/libde265
    REF "v${VERSION}"
    SHA512 3e8de169ac6dfcdb67558ea762c02de2b71bd47e3755c5c604893c53b211ab7d43c4d55ee2d178819994303c917620c091a5a413e35ab0d25eb8c78e04f8f254
    HEAD_REF master
    PATCHES
        fix-arm-neon-clang.patch
        pkgconfig-cxx-linkage.diff
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
