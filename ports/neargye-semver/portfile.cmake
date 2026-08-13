set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Neargye/semver
    REF v${VERSION}
    SHA512 ba3a53a5304f62fe40a96b10f4bd611a2a13caf8e634ae049b56363c6f93ec665a8b7e0c6b2e2ffdc9efe7900d3c181f1ef5502643314cfeb304fe84add9ce83
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

