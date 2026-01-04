vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick_logger
    REF "v${VERSION}"
    SHA512 b61f81b80a7261a4fc32e6ab089888dac2f7b2c6b0875deefc56778a284c807148fe44f76bac9bd8a7bf271e39a817e7a0038812152ab07aaa627952b0d472f7
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
    PACKAGE_NAME slick_logger
    CONFIG_PATH lib/cmake/slick_logger
)

# Header-only library - remove lib directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
