vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO smoked-herring/sail
    REF 3acfd81
    SHA512 571ba82a53b5da900cb8eabc09ec72c9220dd10ea1caa306f9d28d4316a0f30138e052b4615f35c17df2219251a0f50aee59d54d3c20aa4a23541089d3285c27
    HEAD_REF feature/vcpkg
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DSAIL_VCPKG_PORT=ON
        -DSAIL_BUILD_EXAMPLES=OFF
        -DSAIL_BUILD_TESTS=OFF
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

# Remove duplicate files
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include
                    ${CURRENT_PACKAGES_DIR}/debug/share)

# Move codecs
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/sail ${CURRENT_PACKAGES_DIR}/bin/sail)
file(REMOVE ${CURRENT_PACKAGES_DIR}/lib)

file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/sail ${CURRENT_PACKAGES_DIR}/debug/bin/sail)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/lib)

# Move cmake configs
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sail)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/sail RENAME copyright)
