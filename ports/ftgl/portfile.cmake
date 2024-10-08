vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO frankheckenbach/ftgl
    REF v${VERSION}
    SHA512 5a0d05dbb32952e5aa81d2537d604192ca19710cd57289ae056acc5e3ae6d403d7f0ffc8cf6c1aada6c3c23a8df4a8d0eabb81433036ade810bca1894fdfde54
    HEAD_REF master
    PATCHES
      fix-cmake.diff # https://github.com/frankheckenbach/ftgl/commit/835f2ba7911a6c15a1a314d5e3267fa089b5a319
      fix-gl-flags.diff # https://github.com/frankheckenbach/ftgl/commit/778b8f21ba0b71289aef37e3422d008456445971
      install-pkgconfig.diff # https://github.com/frankheckenbach/ftgl/commit/8763fa4e413e015e46376697fb8ab59ed31c2ff5
      02_enable-cpp11-std.patch
      freetype-usage.diff
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_CxxTest=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
)

vcpkg_cmake_install()
if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
else ()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(
        "${CURRENT_PACKAGES_DIR}/include/FTGL/ftgl.h"
        "ifdef FTGL_LIBRARY_STATIC"
        "if 1//ifdef FTGL_LIBRARY_STATIC"
    )
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
