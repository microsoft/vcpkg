vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-shm
    REF "v${VERSION}"
    SHA512 0183bbd24b8eae4177964a4fcd812d54cf83466c7b0a8aab50f10ade9453328a33860d7c6fc4b488cb444b5703a2a8958420af7cefa7af13ac84b94f2993d401 
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
