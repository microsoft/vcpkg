vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpusz/units
    REF v0.7.0
    SHA512 72175f34f358d0741650ce9c8a7b28fced90cc45ddd3f1662ae1cb9ff7d31403ff742ee07ab4c96bd2d95af714d9111a888cf6acccb91e568e12d1ef663b2f64
    PATCHES
        cmake.patch
        config.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

# Handle copyright/readme/package files
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
file(INSTALL "${SOURCE_PATH}/README.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug"
                    "${CURRENT_PACKAGES_DIR}/lib") # Header only