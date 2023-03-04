# Github config
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JustWhit3/osmanip
    REF "v${VERSION}"
    SHA512 7cd03974e3f78e2531e561833830d66bc2e0dc115aed48f69c6cdf1c4b8a2bd18b05444003f816f670f41aeb08dc899f064de9f4c5b369118f1892e9dedf1204
    HEAD_REF main
)

# Main commands
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DOSMANIP_TESTS=OFF
)
vcpkg_cmake_install()

# Move cmake configs
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/osmanip)

# Remove duplicate files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
