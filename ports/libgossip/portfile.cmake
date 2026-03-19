vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO caomengxuan666/libgossip
    REF "v${VERSION}"
    SHA512 ae765138fac7077af09ce8ca769b5bf1bd6ca0a81e17cc4b397436309152fd8678f29ce699fc6534d56c5bead980b8b7cf0fbb7df528ef805c51d3210ab1eb24
    HEAD_REF main
    PATCHES
        fix-dependencies.patch
        remove-export-headers.patch
        support-uwp.patch
)
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
    -DBUILD_TESTS=OFF
    -DBUILD_EXAMPLES=OFF
    -DBUILD_PYTHON_BINDINGS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libgossip)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
