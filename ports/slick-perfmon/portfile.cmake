set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-perfmon
    REF "v${VERSION}"
    SHA512 5ae0bb54d716a24d15407f66cf68f4732f62c237b8899e1582aec8309ab23093b2359af6e36b6f65153005342e07d69b9e933d412ef73a28ff71a9731c126342
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
