vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tristanpenman/valijson
    REF "v${VERSION}"
    SHA512 2b3a3f6f29d576bfdd7460f69bb8efceee886ab352d2b09c60ced24e1707bbf3e05329d6ec36758905a424f7d615f18cdb874fe9d9a5d1b2efd9cc4a2cbf9a29
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
