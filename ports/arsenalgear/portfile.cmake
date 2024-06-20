# Github config
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JustWhit3/arsenalgear-cpp
    REF "v${VERSION}"
    SHA512 27f2979da2d75851d5f8a63868d49b2f5b82064477a1c816667aaf0283e87f854712ab4aa473a3ef36c6ff895bb781c3b095ff617bf134051531aee9b8f03fd3
    HEAD_REF main
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
