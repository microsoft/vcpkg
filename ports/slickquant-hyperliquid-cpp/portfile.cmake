vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/hyperliquid-cpp
    REF "v${VERSION}"
    SHA512 afa9b2b1a9879658c96632f1ae1f5c3e0b963d39cda88b4e86447f534ed809d11c1be69caf1d22ff12344e0f40a15cbcc2cd4c84bd1f0a3480a610bb6be892f1
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

vcpkg_cmake_config_fixup(PACKAGE_NAME hyperliquid-cpp CONFIG_PATH share/hyperliquid)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
