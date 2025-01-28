# Github config
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JustWhit3/arsenalgear-cpp
    REF "v${VERSION}"
    SHA512 fd7a9029b74483dce4bac331b61fc76b3b7d2d9cf2cc43e45b3c7f1c3f458ccb3ca9cae779896a16cadf7fe6730db96ec3fa8a49972f8822b86b3f085d19fc71
    HEAD_REF main
    PATCHES
        disable-cppcheck.patch
)

# Main commands
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DARSENALGEAR_TESTS=OFF
)
vcpkg_cmake_install()

# Move cmake configs
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/arsenalgear)

# Remove duplicate files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
