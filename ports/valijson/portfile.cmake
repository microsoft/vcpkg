vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tristanpenman/valijson
    REF "v${VERSION}"
    SHA512 4916e12dc45312462a7abbc2707f5c1edfe129feb03e73afebf11a80ac6fb2f4469fdb4d83174d1c0565f8553ff958b1dc0ea78132d7063bbf640de0ade1676b
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
