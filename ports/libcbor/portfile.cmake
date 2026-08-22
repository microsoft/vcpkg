vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PJK/libcbor
    REF "v${VERSION}"
    SHA512 e580543d9cb567d484e14c3057c5c1672f012879abe3f04ead64bf0f14b95b986fcc26602b0ffc2b247e9bfbd8a914d676c25d4f62230ac8fd5a6727f7d34595
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
