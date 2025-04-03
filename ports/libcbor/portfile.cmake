vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PJK/libcbor
    REF "v${VERSION}"
    SHA512 07fcf4e758742e6d430eaab0b333e8f836587c6eeb3f15eea094f8e7881804998382335737df6e2a5d0f570eb9cb46bae6c6d1058aeca8fa29b973a98ae6b69b
    HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_POLICY_DEFAULT_CMP0054=NEW
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
