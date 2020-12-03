vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO smoked-herring/sail
    REF cc46dd4
    SHA512 ce265510e1150e52f72da64ea88839d6bbb7e7427e1d14d0b273ec1bc7863cf68ced13c28388c38a1e1868cebea056a4f828043e60a264f3cfae9e77e91b3575
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
