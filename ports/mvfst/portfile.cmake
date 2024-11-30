vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebook/mvfst
    REF "v${VERSION}"
    SHA512 662a86f4b1b1d60f05c9198687c668e334061d00109148d3cd4643fc10c38c7bf2810fbb6fa1d01a25847e36c54a6cc2f6fb9e1405923f6a376be50f44252b29
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mvfst)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
