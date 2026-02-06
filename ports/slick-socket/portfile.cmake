vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-socket
    REF "v${VERSION}"
    SHA512 6fe2a2fa8d5b1ad8abac365027438ee98552ba7c67a0dae508df1a28f3416647c3804b421427491eb2c593d4be070f639034df054fd5b12bf65e156d18b0a31c
    HEAD_REF main
)

# Header-only library (header-only wrapper, links to wepoll on Windows)
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SLICK_SOCKET_EXAMPLES=OFF
        -DBUILD_SLICK_SOCKET_TESTING=OFF
)

vcpkg_cmake_install()

# Fix up CMake config files
vcpkg_cmake_config_fixup(
    PACKAGE_NAME slick-socket
    CONFIG_PATH lib/cmake/slick-socket
)

# Header-only library - remove lib and debug directories
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

# Install usage
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")