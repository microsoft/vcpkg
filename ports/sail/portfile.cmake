vcpkg_fail_port_install(ON_TARGET "UWP")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO smoked-herring/sail
    REF 593269c5cd
    SHA512 fba2c7cde47952a7c0474ef23f1e6f05f5c1f50e533ea6d7e3778126987d114b386ff79000148439c7dc318f8a6133175efbe308ee6ce03fa9d80847bbf78023
    HEAD_REF feature/static
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SAIL_STATIC)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSAIL_VCPKG_PORT=ON
        -DSAIL_STATIC=${SAIL_STATIC}
        -DSAIL_COMBINE_CODECS=ON
        -DSAIL_BUILD_EXAMPLES=OFF
        -DSAIL_BUILD_TESTS=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# Remove duplicate files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/share)

# Move cmake configs
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sail)

# Fix pkg-config files
vcpkg_fixup_pkgconfig()

# Handle usage
file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
