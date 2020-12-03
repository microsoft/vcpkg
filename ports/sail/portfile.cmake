vcpkg_fail_port_install(ON_TARGET "UWP" "OSX" "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO smoked-herring/sail
    REF 3cc129c
    SHA512 079c1753e096b1dc01c3b43794f9f34290fb8c844b939683ca0c9ab86f6a4b0cf09370b4adc0ef1e26929fbd9c4ca25856b9393c42fba9d9b823d916596db2e2
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
