include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO c-libs/gherkin-c
    REF e63e83104b835e217140e9dc77d9ce2bb50f234e
    SHA512 a99b3f695257b45df8ff7b8ec46bff28991cf2b9bc51a25247550471c724bd14ee64340db684f096131f47d7f4ff278d23dda546e7dfe29134bbc1dbccaf0d1e
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS 
        -DBUILD_GHERKIN_TESTS=OFF
)
vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/gherkin-c RENAME copyright)
