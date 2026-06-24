vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/hyperliquid-cpp
    REF "v${VERSION}"
    SHA512 50410e7e54ae9bae6608720598923425b6de1fa235f03507360e80b073d9045d36b408e1d817d1c14beebd949d119d115c1863c070a41b8004dff602a0b88a09
    HEAD_REF main
    PATCHES
        slick-net.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DHYPERLIQUID_BUILD_TESTS=OFF
        -DHYPERLIQUID_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME hyperliquid CONFIG_PATH share/hyperliquid)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
