vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CLIUtils/CLI11
    REF v2.3.1
    SHA512 7805a3bff5ce443e93a005341680db1e618d5b0789a697daaac881f9ccac76f855ea3d43c9c5b13c33c2bf590138241df9e55d70e133562272f0859d8341af09
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCLI11_BUILD_EXAMPLES=OFF
        -DCLI11_BUILD_DOCS=OFF
        -DCLI11_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/CLI11)
vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
