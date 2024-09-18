vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO upa-url/upa
  REF "v${VERSION}"
  SHA512 6217d2ec00191d125b94d86ea1bc094d5386ee9ebe7368d5ffa74161ab911d2409833239ff6874b185a7deb838a50a6b06cb79f287d16095227c83494e4fd1b4
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
