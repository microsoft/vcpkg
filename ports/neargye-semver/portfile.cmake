set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Neargye/semver
    REF v${VERSION}
    SHA512 194f679224a371a4434bc32f14717ef0f83c796e878a3ada4aa2e8c925e5e64aaa63f703d891a8ae6b15452e16cf714983e3b0a15e37185275e82e5120393f44
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

