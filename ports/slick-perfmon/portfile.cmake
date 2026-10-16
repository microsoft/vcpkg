set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-perfmon
    REF "v${VERSION}"
    SHA512 ce8e1f5993ec68d6402624af4dec57df04479b0c7f6d01059fb10e0b7bd6174c540ecc18c4dca2380d9d803070fe61e5454c9be4e37c3de31b235ea8160fc0fd
    HEAD_REF main
    PATCHES
        slick-dependencies.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_SLICK_PERFMON_TESTS=OFF
        -DBUILD_SLICK_PERFMON_EXAMPLES=OFF
        -DBUILD_SLICK_PERFMON_COLLECTOR=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH lib/cmake/slick-perfmon
)

# Header-only library - remove lib directory
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
