vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hellobertrand/zxc
    REF v${VERSION}
    SHA512 98b3a90428fb28ff46d32b46593c72316dff56932ebec75e8f75ddec29dce151d2abac8c035cdd1bfa10b7a316d4bdde32d653f3ffacdda225961dad9687df2e
    HEAD_REF main
)

# Remove vendored rapidhash to use the rapidhash port instead
file(REMOVE "${SOURCE_PATH}/src/lib/vendors/rapidhash.h")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DZXC_NATIVE_ARCH=OFF
        -DZXC_ENABLE_LTO=OFF
        -DZXC_BUILD_CLI=OFF
        -DZXC_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/zxc)
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
