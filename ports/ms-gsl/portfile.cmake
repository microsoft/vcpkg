#header-only library with an install target
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF v${VERSION}
    SHA512 c613937d225a72cd6fb66d68019ffe70bb16e99a8b9c13664dbaebf3c5bfde4888b2299174b3d668cb234f74821e20d9de3fa19febdee8fb733cb30a50089cd4
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
