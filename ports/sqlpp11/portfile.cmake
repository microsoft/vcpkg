include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rbock/sqlpp11
    REF 0.57
    SHA512 6bf48189f35cf2ff20b09e27ab83b6fb36415bed7e5c818c1ea2c9b30b5fe0a60c0f7e9930e92a0637c7b567ccfead4a9208a3aff99be89fed361778cf8c45f1
    HEAD_REF master
    PATCHES FixForMSVC.patch
)

# Use sqlpp11's own build process, skipping tests
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
    -DENABLE_TESTS:BOOL=OFF
)

vcpkg_install_cmake()

# Move CMake config files to the right place
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake)

# Delete redundant and unnecessary directories
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/sqlpp11 RENAME copyright)
