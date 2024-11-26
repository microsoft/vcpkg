vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO upa-url/upa
  REF "v${VERSION}"
  SHA512 c21a48f74dc31f9114574c69e2ce17c7957f50c65bc99f45acb9f7e88930b1b7e125c90cf3b7f002e63d8456f6f7377d0e28ffc7c7e5ffe87c4d414ef5845733
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
