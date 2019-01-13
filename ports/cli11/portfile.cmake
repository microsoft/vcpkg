include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO CLIUtils/CLI11
    REF v1.6.2
    SHA512 0160323a7a87ecdf5cff081a4270a30977b87f0592041d8fde84ec655b28cdbc40813567f95df375a4f6f953b60a638deacfb3cc5dec562c4d348dcc532f0ab7
    HEAD_REF master
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DCLI11_TESTING=OFF
        -DCLI11_EXAMPLES=OFF
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/CLI11)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/cli11 RENAME copyright)

# Post-build test for cmake libraries
# vcpkg_test_cmake(PACKAGE_NAME cli11)
