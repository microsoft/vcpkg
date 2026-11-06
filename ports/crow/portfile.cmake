vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CrowCpp/crow
    REF "v${VERSION}"
    SHA512 08f8fbd6d8201ef905723f7ef57de411ca09f158c8171c2bc46a0cf202d0e5af84ff588b03b03ade80409cf7cc8c6b6d7ad883831cb1a05e881d52fe1b90fca8
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

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug"
    "${CURRENT_PACKAGES_DIR}/lib"
)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/README.md"
)
