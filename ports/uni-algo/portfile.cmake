vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uni-algo/uni-algo
    REF "v${VERSION}"
    SHA512 031d6ec2a1a2c09972a68d7b9bf49a209441e69802d5d8d37b2a37d9b6e002427496d420629d2119dc1d0e80f38c7b220e253b0858db5f172789472447041799
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DUNI_ALGO_INSTALL=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(NO_PREFIX_CORRECTION)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
# Remove empty directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/uni_algo/impl/doc")

# Install copyright and usage
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
