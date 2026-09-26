set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-perfmon
    REF "v${VERSION}"
    SHA512 63be9fd96f81ab4a2127cc3baf9eee04cd2d78426c01408cca3d2f31f2fdd1c137845ccbe491a011b68a309bb8edf5aace16efc2b8118a80ed1cb942c1406159
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
