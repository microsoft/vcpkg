vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-socket
    REF "v${VERSION}"
    SHA512 2f9aeec062e3b15c57f25116d6f00e81faac4a4240d897ac275c2bfae06c1e7e23d28d4b4f0998ef770b54a10d041e43a30c101280c6797aa4f3e12bf649d664
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
