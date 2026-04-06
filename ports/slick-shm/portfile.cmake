vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-shm
    REF "v${VERSION}"
    SHA512 2ca3edb663efef81ec5179687305f5081ef1d8ac11c250aa90db5fabf49e445dce74867e9c5ad532edb3c3006dcb4a59dd9692bbed66b2a0cb16e50789f77a52 
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSLICK_SHM_BUILD_EXAMPLES=OFF
        -DSLICK_SHM_BUILD_TESTS=OFF
)

vcpkg_cmake_install()

# Fix up CMake config files before removing lib directory
vcpkg_cmake_config_fixup(
    PACKAGE_NAME slick-shm
    CONFIG_PATH lib/cmake/slick-shm
)

# Header-only library - remove lib directory after config fixup
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
