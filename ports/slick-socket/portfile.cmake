vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-socket
    REF "v${VERSION}"
    SHA512 92e06ba13bdc08991b3b41b7b4d0acfa6585b478dda267ece8082b8bac11590c71fc0e3509703565048dfe97612f9ab577ca87ab1cf694ef52affe347f32a6e9
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
