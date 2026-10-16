vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/hyperliquid-cpp
    REF "v${VERSION}"
    SHA512 8770289c3862733818c781ac188efd4652e4a501859a6701a847016d00c97cd687d0f2535027a4d651f8711abcb87951ff78eee289ad6448284e7f25366a63f7
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
