include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rbock/sqlpp11
    REF 0.58
    SHA512 c391e72638a748e0e25b53176dc371ba468bc14bdcb6dda2f2418c4ab4d620ebc5507ee284ff81c3104888d0d959703c6c91b55ccd69a8641b07dcb20cd56209
    HEAD_REF master
    PATCHES ddl2cpp_path.patch
)

# Use sqlpp11's own build process, skipping tests
vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
    -DENABLE_TESTS:BOOL=OFF
)

vcpkg_install_cmake()

# Move CMake config files to the right place
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Sqlpp11 TARGET_PATH share/sqlpp11)


# Delete redundant and unnecessary directories
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Move python script from bin directory
file(COPY ${CURRENT_PACKAGES_DIR}/bin/sqlpp11-ddl2cpp DESTINATION ${CURRENT_PACKAGES_DIR}/scripts)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/sqlpp11 RENAME copyright)
