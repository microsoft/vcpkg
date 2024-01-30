vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO LibreDWG/libredwg
  REF ${VERSION}
  SHA512 8696289ea7ff542bd48d4e1f0e959b95574a7741ba0c80238ad31aff28f1861f0c00dfb1dc78e998b043a4300ff976ba324f5a41195f799f9d31e2b5be288bc7
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
file(WRITE "${SOURCE_PATH}/.version" ${VERSION})

# Fix https://github.com/LibreDWG/libredwg/issues/652#issuecomment-1454035167
if(APPLE)
  vcpkg_replace_string("${SOURCE_PATH}/src/common.h"
    [[defined(COMMON_TEST_C)]]
    [[1]]
  )
  vcpkg_replace_string("${SOURCE_PATH}/src/common.c"
    [[defined(COMMON_TEST_C)]]
    [[1]]
  )
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    ${FEATURE_OPTIONS}
    -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-libredwg CONFIG_PATH share/unofficial-libredwg)

if("tools" IN_LIST FEATURES)
  vcpkg_copy_tools(TOOL_NAMES dwg2dxf dwg2SVG dwgbmp dwggrep dwglayers dwgread dwgrewrite dwgwrite dxf2dwg AUTO_CLEAN)
  vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/libredwg")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
