vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO caomengxuan666/libgossip
    REF "v${VERSION}"
    SHA512 ee463b28d6eea77f0d5ff63e849c768f054d2e8c7fbffb83a5dd38f05a9bec1c2fa9d25fddbb52e29d122cc3c8a735e6b901221aa34234f314d0f3c1cdf71d57
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
