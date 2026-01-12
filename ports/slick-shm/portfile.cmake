vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick_shm
    REF "v${VERSION}"
    SHA512 bffa11f9c1171c13ce31c0f2a3da0194ed679557fa7162463115334caf04c8308492d52c8fc6e1a7fbda14ebba355607f67dd1df329176a23d31e92127925a26 
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
    PACKAGE_NAME slick_shm
    CONFIG_PATH lib/cmake/slick_shm
)

# Header-only library - remove lib directory after config fixup
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
