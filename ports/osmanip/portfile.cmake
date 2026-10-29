# Github config
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JustWhit3/osmanip
    REF "v${VERSION}"
    SHA512 ac5435ce5d39440851a01ee1576b7a543979efbf374a27ec32d63716361ef91662c353c2e39fecbd7e01059e8676f952f6851111643a55f941695dbbc6f03da4
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
