vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-socket
    REF "v${VERSION}"
    SHA512 42f9848c6487957a9c24bb89259a9ca7e67bde1fe89c6a7ada32e03f23c6de378a35ede3917e9719564b5baa8b8f6fc26056f9768ec67d5773df6d4648b3ab19
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
