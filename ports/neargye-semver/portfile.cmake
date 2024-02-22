set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Neargye/semver
    REF v${VERSION}
    SHA512 b620a27d31ca2361e243e4def890ddfc4dfb65a507187c918fabc332d48c420fb10b0e6fb38c83c4c3998a047201e81b70a164c66675351cf4ff9475defc6287
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

