vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tristanpenman/valijson
    REF v${VERSION}
    SHA512 a1f9aabfcd150a36ed16c5642027a9c524ec044dd1eb636a81a75f2226b7b665cc3d2f4cd375786be8fc9dadf2c6938df17d6e6fa13f27c621fe2ca35e0d13ee
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
