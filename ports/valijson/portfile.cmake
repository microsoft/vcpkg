set(VCPKG_BUILD_TYPE release) # headers only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO tristanpenman/valijson
    REF "v${VERSION}"
    SHA512 fa58f4325bebd93c5fdaa9144fe5bc2ec91c5f4f6d6a42f61da8b06190a9c8b0a1c36ba198fd13a773cd93f7fff0c99386f235f3ddb559879e1f03f00435af2a
    HEAD_REF master
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -Dvalijson_BUILD_TESTS:BOOL=OFF
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/valijson")

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/lib"
    "${CURRENT_PACKAGES_DIR}/debug/lib"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
