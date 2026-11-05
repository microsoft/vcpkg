set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-logger
    REF "v${VERSION}"
    SHA512 5aea3b41adae4b066312d6801c6be2d98bf2e28a31db1c47669e96764cc5577014a6dd4f394e58945fd71628f242fb069b6367a069a99b0b44374ca76aee384a
    HEAD_REF main
    PATCHES
      slick-queue.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        -DBUILD_SLICK_LOGGER_TESTING=OFF
        -DBUILD_SLICK_LOGGER_EXAMPLES=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/slick-logger
)

# Header-only library - remove lib directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
