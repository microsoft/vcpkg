vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-logger
    REF "v${VERSION}"
    SHA512 0f54320b9afe40177d13b33ccd69bb045ede5e707fd347a3e32800521cf96ed1da810f45a608729f8b01ef87ce0a4c34b1166119d8ba9b51a26adcd59f895015
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
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    PACKAGE_NAME slick-logger
    CONFIG_PATH lib/cmake/slick-logger
)

# Header-only library - remove lib directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
