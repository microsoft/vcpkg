#header-only library with an install target
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Microsoft/GSL
    REF v${VERSION}
    SHA512 f325c70fb02ead99c5be333baa0793573dd091fe111b20ff13b2d524b71f1357bbc365a66684a8c791796095284cc6a968fc3c7284a0b3c0646a38a61e46792c
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
