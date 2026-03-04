vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO hellobertrand/zxc
    REF v${VERSION}
    SHA512 150a693087956ef8f5ec1a909059b16dda00b776904a1d044e2a56a5c64ecae68401154a6a1f30a3a83f500a77401b901c28919412d17375e96d7cecae7027ee
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
