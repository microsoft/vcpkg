vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Tehreer/SheenBidi
    REF "v${VERSION}"
    SHA512 9efd97b3c212350debaf3e0f3cf022f6b4c93e3de80a77ed92ddf34a2da23c1ddeb3dc5d90b357bd7f3cb3c8c8780c045b7c897836d771bdc96e35d2b9b1935b
    PATCHES
        cmake-install.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSB_CONFIG_UNITY=ON
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/SheenBidi)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
