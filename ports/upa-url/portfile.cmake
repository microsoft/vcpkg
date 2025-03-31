vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO upa-url/upa
  REF "v${VERSION}"
  SHA512 285c5e8b81da124a2e788cb7947cab3e917405f635e6a11d9f76f51c92187bf5670c529510844cb31a644a0a32cf231374e8b97279310a77230cd7b0e67581af
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
