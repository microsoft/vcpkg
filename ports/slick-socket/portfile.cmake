vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-socket
    REF "v${VERSION}"
    SHA512 6fe2a2fa8d5b1ad8abac365027438ee98552ba7c67a0dae508df1a28f3416647c3804b421427491eb2c593d4be070f639034df054fd5b12bf65e156d18b0a31c
    HEAD_REF main
)

vcpkg_cmake_install()

# Fix up CMake config files before removing lib directory
vcpkg_cmake_config_fixup(
    PACKAGE_NAME slick-socket
    CONFIG_PATH lib/cmake/slick-socket
)

# Header-only library
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")