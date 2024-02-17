# header-only library

# Github config
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JustWhit3/ptc-print
    REF v1.4.1
    SHA512 45f3008cb848f464ac0355660e7cdbd40db60338a4db5e35d29285c8c1afc0556c8dea6ac0e6939837916ec138dd8e385709d1fa89651d3404418cf3e7948fd9
    HEAD_REF master
)

# Main commands
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DPTCPRINT_TESTS=OFF
)
vcpkg_cmake_install()

# Move cmake configs
vcpkg_cmake_config_fixup(PACKAGE_NAME ptcprint CONFIG_PATH lib/cmake/ptcprint)

# Remove duplicate files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/lib" 
                    "${CURRENT_PACKAGES_DIR}/lib"
                    "${CURRENT_PACKAGES_DIR}/debug")

# Install license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
