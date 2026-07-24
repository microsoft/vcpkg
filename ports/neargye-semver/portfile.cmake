set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Neargye/semver
    REF v${VERSION}
    SHA512 dbef2a5d6d6e38b1136edb0576b6b1480c5d646caffcce07a92782bb2678ca1478be5c4a1451e0c1beb887d28cf19af2c0f5f006462e0a5c47b8a59499d59024
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
      -DSEMVER_OPT_INSTALL=ON
      -DSEMVER_OPT_BUILD_EXAMPLES=OFF
      -DSEMVER_OPT_BUILD_TESTS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME semver CONFIG_PATH "lib/cmake/semver")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib") # empty; rm for vcpkg validity checks

