vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO upa-url/upa
  REF "v${VERSION}"
  SHA512 5a140074d1d92ac41c6da6f615a2d1c4bb5d09a43550a16967e4a7b40f00cc1245fc0c7acb572300d96253763ef3f36394f720dd8777658723d1d302c0ee9938
  HEAD_REF main
  PATCHES
    cxx-standard.patch
)

if("cxx11" IN_LIST FEATURES)
  set(UPA_CXX_STANDARD 11)
else()
  set(UPA_CXX_STANDARD 17)
endif()

vcpkg_replace_string(${SOURCE_PATH}/include/upa/config.h
  "@UPA_CXX_STANDARD@" "${UPA_CXX_STANDARD}"
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DCMAKE_CXX_STANDARD=${UPA_CXX_STANDARD}
    -DCMAKE_CXX_STANDARD_REQUIRED=ON
    -DUPA_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME "upa" CONFIG_PATH "lib/cmake/upa")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
