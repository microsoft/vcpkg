vcpkg_fail_port_install(ON_TARGET "UWP" "OSX" "Linux")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO smoked-herring/sail
    REF 3672fd1
    SHA512 a02dfcd8eeedd6400c6041542579149a95d9933ec70e2fdfad71de847af3eb3f268b37529be14faefe6c71bf96ed11f6405399c64eac7a154582d86195fa361d
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
file(RENAME ${CURRENT_PACKAGES_DIR}/lib/sail       ${CURRENT_PACKAGES_DIR}/bin/sail)
file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/sail ${CURRENT_PACKAGES_DIR}/debug/bin/sail)

# Move cmake configs
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/sail)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
