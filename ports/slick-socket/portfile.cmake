vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-socket
    REF "v${VERSION}"
    SHA512 98092f8e4a9ebe70e05120d82deedfffa7cbadf1ccdcc77ed4b5b2beff6e0ef0def5947bf3e80b8508288a7d036799e9a9a15f667941ebab748e40a3d70ff93f
    HEAD_REF main
)

# Header-only library (header-only wrapper, links to wepoll on Windows)
vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SLICK_SOCKET_EXAMPLES=OFF
        -DBUILD_SLICK_SOCKET_TESTING=OFF
        -DSLICK_SOCKET_WARNINGS_AS_ERRORS=OFF
)

vcpkg_cmake_install()

# Fix up CMake config files
vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/slick-socket
)

# Header-only library - remove lib and debug directories
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")