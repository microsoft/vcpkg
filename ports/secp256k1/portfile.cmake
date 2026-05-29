vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO bitcoin-core/secp256k1
    REF v${VERSION}
    SHA512 747bda9276c02a87511c2d3275ec8894db1b7b99dcc9ab9a48497659c2eb512c555cc5f5f2c0269b00237e7177aa3790a5c7cf635ee695f2d440f0ddcb8672ab
)

vcpkg_cmake_configure(
	SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSECP256K1_BUILD_BENCHMARK=OFF
        -DSECP256K1_BUILD_TESTS=OFF
        -DSECP256K1_BUILD_EXHAUSTIVE_TESTS=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/libsecp256k1" PACKAGE_NAME libsecp256k1)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
