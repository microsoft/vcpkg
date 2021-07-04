vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mpusz/units
    REF 33ad51311b835efb7f7767473f971c02a3140073
    SHA512 18c9a4bb1812d7ab59e86d3eef5f62aa760c8f78eac81086bd3b25f7e2d359f2fba71b0298cf91ecb31dbe13846f2e5ce75133b0db534020102b788dd1c1a1da
    PATCHES
        cmake.patch
        config.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})
# Handle copyright/readme/package files
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(INSTALL ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug"
                    "${CURRENT_PACKAGES_DIR}/lib") # Header only