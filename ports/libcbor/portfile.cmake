vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO PJK/libcbor
    REF "v${VERSION}"
    SHA512 c14aaa55c0c82e09b9eb2cc6847951d1bac8a081a247776c507d5450367da5717b1056bad09fb0f0178311de8754e8f89c060e0fc0f400fafdc42de441421e66
    HEAD_REF master
    PATCHES cmake-config.diff
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
