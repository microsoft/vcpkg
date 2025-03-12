vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO upa-url/upa
  REF "v${VERSION}"
  SHA512 e3110a0714bcb28c9c740aae0345a016816d9872cbec61321fce6d3be6132bcf01fbed55310013b84b6c37bf25c818de4ff7c328ac8e772c745316fca49f65ef
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
