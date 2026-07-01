vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/hyperliquid-cpp
    REF "v${VERSION}"
    SHA512 8455c8669812d6292117c70dcfb886645a165c8aab957af59d5a068e40959847dc2bd7c893557bb7e228e489f34be7748dea16b24c5632eda8992c0e214cfa4b
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
