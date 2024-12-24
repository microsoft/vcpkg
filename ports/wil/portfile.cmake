#header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/wil
    REF "v${VERSION}"
    SHA512 5701001b2c7174dafa5b7b6494b65b982245dfa31131b40542a00063b4f6d26c142c789e64b88367f5f1cdddf882780610fdf724f0bf6b3663d8ba9e3214b5b2
    HEAD_REF master
)

# WIL is header-only, so we don't need to build it in both modes
set(VCPKG_BUILD_TYPE release)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWIL_BUILD_TESTS=OFF
        -DWIL_BUILD_PACKAGING=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/WIL)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Install natvis files
file(INSTALL "${SOURCE_PATH}/natvis/" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}/natvis")

# Install copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")