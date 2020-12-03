vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO smoked-herring/sail
    REF 915a1f6
    SHA512 c72c78b75ffe87d3c331a9606899e45e24ca6936b10a414b316f69623bc204ae24647f5baf726c4b9298fb2accf86e5345e581202ccb669e21366dcebda4ffbb
    HEAD_REF feature/vcpkg
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DSAIL_VCPKG_PORT=ON -DSAIL_BUILD_EXAMPLES=OFF -DSAIL_BUILD_TESTS=OFF
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
