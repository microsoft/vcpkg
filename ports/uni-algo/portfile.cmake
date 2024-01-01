vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO uni-algo/uni-algo
    REF "v${VERSION}"
    SHA512 55abef9b225aba8681439c83c08636b1bebf8faa73e7c8f137fc6cb3c8c6d3c5e0488082c852522fd5680d07366574d8acb25ce762e164c53d9014f249cb572f
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

# Install copyright and usage
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
