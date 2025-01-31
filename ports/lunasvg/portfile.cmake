vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO sammycage/lunasvg
  REF "v${VERSION}"
  SHA512 d79c7e35164df971a29145427316adca778416866635a97050f090ffdea1c313cba11255d9993ba7e4cbb3c7faa5b6ff0767e8c7739a680d34be377e6b9c5091
  HEAD_REF master
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DCMAKE_REQUIRE_FIND_PACKAGE_plutovg=1
    -DLUNASVG_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/lunasvg)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/lunasvg/lunasvg.h" "defined(LUNASVG_BUILD_STATIC)" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
