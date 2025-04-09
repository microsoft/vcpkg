vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO sammycage/lunasvg
  REF "v${VERSION}"
  SHA512 6ea8ef74a18047e2714aacc6c162c42519246c38061290053461e7c5c0922234534a031bdb84eaff7bea46da4d8edd1e3cdd00d710c066600c9024fa2a134a03
  HEAD_REF master
  PATCHES
    # temporary patch. It should be removed once the new version of lunasvg is released.
    fix-plutovg.patch
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
