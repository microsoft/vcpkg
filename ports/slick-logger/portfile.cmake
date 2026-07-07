vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-logger
    REF "v${VERSION}"
    SHA512 8af1f00e289202bdf74f7bb1c737cf60554fd216e765e32f1954dfbc06db592743880b6614637812b99abe28d7b0878a1d7a0d45cc96a34a743d60e2a0a426fc
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
