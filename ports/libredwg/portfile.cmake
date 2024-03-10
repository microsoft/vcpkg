vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO LibreDWG/libredwg
  REF "${VERSION}"
  SHA512 cf0baf477d053eb6ab2feaeda187f2d92211c7d28aa50318c1c8d7acf1b9c463258fa3a388dddce266bf44e0d4e4cf1bd3aa591c918f8a253515919e5c1b3f57
  HEAD_REF master
  PATCHES
    fix_install.patch
    fix_dependency.patch
    fix_arm64_build.patch
)

# If generate dwg manipulation tools
vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        tools LIBREDWG_LIBONLY
)

# libredwg will read the version
file(WRITE "${SOURCE_PATH}/.version" "${VERSION}")

# Fix https://github.com/LibreDWG/libredwg/issues/652#issuecomment-1454035167
vcpkg_replace_string("${SOURCE_PATH}/src/common.h"
    [[defined(COMMON_TEST_C)]]
    [[(defined COMMON_TEST_C || defined __APPLE__)]]
)
vcpkg_replace_string("${SOURCE_PATH}/src/common.c"
    [[defined(COMMON_TEST_C)]]
    [[(defined COMMON_TEST_C || defined __APPLE__)]]
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    ${FEATURE_OPTIONS}
    -DBUILD_TESTING=OFF
    -DDISABLE_WERROR=ON
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-libredwg CONFIG_PATH share/unofficial-libredwg)

if("tools" IN_LIST FEATURES)
  vcpkg_copy_tools(TOOL_NAMES dwg2dxf dwg2SVG dwgbmp dwggrep dwglayers dwgread dwgrewrite dwgwrite dxf2dwg AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
