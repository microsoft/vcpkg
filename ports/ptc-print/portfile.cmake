# Github config
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO JustWhit3/ptc-print
    REF v1.4.0
    SHA512 17218b096bc616a448d5c257b29f3e6c5a263cb56ff0361fb4be19206daf687c012cad9c6fb551aec1d16024eb563962cd15fccff0b7c3ab71cce23dc0846a95
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
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ptcprint)

# Remove duplicate files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
                    "${CURRENT_PACKAGES_DIR}/debug/lib" 
                    "${CURRENT_PACKAGES_DIR}/lib"
                    "${CURRENT_PACKAGES_DIR}/debug")

# Install license
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/ptc-print" RENAME copyright)
