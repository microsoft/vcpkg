vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/hyperliquid-cpp
    REF "v${VERSION}"
    SHA512 a585e2f43005b2547a5b4e6ba641fbf9581b89e90de18277bc1946db16a2603307af6f936803b4451badaaa0a00d3c831d8a898783dddb67ae389e21b4f6ca31
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
