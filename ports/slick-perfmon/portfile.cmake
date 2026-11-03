set(VCPKG_BUILD_TYPE release) # header only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SlickQuant/slick-perfmon
    REF "v${VERSION}"
    SHA512 08c048b86c75e9e6706bc3146cdc5e91a927a803b2eb322f69a06917bc8c063d261d8617046be765effab41ba5b4d36dcb4b4776fbc593679e4e00d919c83d96
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
