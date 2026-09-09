vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CrowCpp/crow
    REF "v${VERSION}"
    SHA512 1d12cfe1a6c2c928d9397e2e3bdb57c5bc425f1509a388d5b3bd68f52aaeb3950f564cd6c5612331cb389165feb0d2a1c6e593ea8f14f68072658376e71f14c3
    HEAD_REF master
    PATCHES remove-cpm.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCROW_BUILD_EXAMPLES=OFF
        -DCROW_BUILD_TESTS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Python3=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Crow)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST
    "${SOURCE_PATH}/LICENSE"
    "${SOURCE_PATH}/README.md"
)
