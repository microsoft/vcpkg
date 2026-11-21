#header-only library with an install target
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF v${VERSION}
    SHA512 fd05d8d04cd281e0d19f491e5dcf570caa2acfa739df3fa0eb83967da2073d1b97eae060da5c93cb051a4e5b1e9258652de5c4daa8611a18fdc63ac8de13c5b9
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
