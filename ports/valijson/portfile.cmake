vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tristanpenman/valijson
    REF "v${VERSION}"
    SHA512 acd8971d3afd3c89255f45367a6b40e71f3b155dd2968afdc49f0b4d381d25da116383a8c7853f93a47e69333b99b969db0abcb25c646d97143afa9523c9d4b9
    HEAD_REF master
)

set(VCPKG_BUILD_TYPE release) # headers only

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -Dvalijson_BUILD_TESTS:BOOL=OFF
)
vcpkg_cmake_install()


vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/valijson")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug/lib")
