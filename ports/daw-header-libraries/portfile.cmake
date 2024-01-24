# Header-only library
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO beached/header_libraries
    REF "v${VERSION}"
    SHA512 6d59950b71c47aaba23ea762c2bd37665c00d65d5d7f9ac4c15d78b758f8c2061d04b26ad9ec8f7bf9540644601d47e801a363f85fcbb8d0b1da8c3de136d32e
    HEAD_REF master
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

# remove empty lib and debug/lib directories (and duplicate files from debug/include)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
