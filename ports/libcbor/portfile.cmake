vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PJK/libcbor
    REF "v${VERSION}"
    SHA512 1d7bcc2a0517e822b722310aac260206cc6c1603db4930737d0a25f5fb4c5318bf1bd79cdc04654b155d620fae0737eb1e03666e4038bdb88c0648c774328d6a
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSANITIZE=OFF
        -DWITH_EXAMPLES=OFF
        -DWITH_TESTS=OFF
)

vcpkg_cmake_build()
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
