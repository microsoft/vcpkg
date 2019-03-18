include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO gocha/sf2cute
    REF fcb6d1075f5bf47c4240f590ad83865276cbe69c
    HEAD_REF master
    SHA512 4664420eb7fc0c24b22e5ea72578519147c3f6852f4cc1f6144560915383d6cf389feefd186ec1aeccb1ee4b48745384868b3fca1d687dc7fe58b4850adcb754
)

file(COPY "${CURRENT_PORT_DIR}/cmake/sf2cute-config.cmake.in" DESTINATION "${SOURCE_PATH}/cmake/")
file(COPY "${CURRENT_PORT_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# move the .cmake files from the given directory to the expected directory by vcpkg
vcpkg_fixup_cmake_targets(CONFIG_PATH share/sf2cute)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/sf2cute RENAME copyright)

# Post-build test for cmake libraries
vcpkg_test_cmake(PACKAGE_NAME sf2cute)
