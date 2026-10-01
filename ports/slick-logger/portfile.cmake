set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-logger
    REF "v${VERSION}"
    SHA512 463f97e08ae8d71ec69874a33d7d4e63b942e610d9ea24230c7b6e950f29c221cd69663ccc4f4e4d0481ca5bfe7b3aeb2023b9de607b5de91ca6bdf756d1dfc5
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
    CONFIG_PATH lib/cmake/slick-logger
)

# Header-only library - remove lib directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
