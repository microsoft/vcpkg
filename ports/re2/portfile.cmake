include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/re2
    REF c1ed8543f1b703ce200212bb5629ba69a2f9b63a
    SHA512 399a7545d3ac678b068118271aaa710cfae2c9c38e27b07d880f04714bbb13a19c69b94d4acbdb459f199920fee4d3d1a7e23e22a364c89b3c8b7100ce9b208e
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS -DRE2_BUILD_TESTING=OFF
)

vcpkg_install_cmake()

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/re2 RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
