#header-only library with an install target
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF v${VERSION}
    SHA512 1db14bebab5f2bc0752214f9bf1b84a056b7d83b4a9d296663c43103387baee60373447f62c4e9bc0b8df06a7ce0571a4e2b4a31441c866894eee3ae258fdfc8
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DGSL_TEST=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME Microsoft.GSL
    CONFIG_PATH share/cmake/Microsoft.GSL
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
