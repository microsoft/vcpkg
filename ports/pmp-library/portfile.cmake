vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO pmp-library/pmp-library
    REF "${VERSION}"
    SHA512 8ee6f731619b92ad3d555b96c9e486446a4b9b3871992b389f9a55a0d07ca9f69cb4e03c1dc1c986357fc5a06ad60b2657ee0d58a78cb5da3c8f5692fb4c8b0f
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPMP_BUILD_EXAMPLES=OFF
        -DPMP_BUILD_TESTS=OFF
        -DPMP_BUILD_DOCS=OFF
        -DPMP_BUILD_VIS=OFF
        -DPMP_STRICT_COMPILATION=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/pmp" PACKAGE_NAME pmp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
