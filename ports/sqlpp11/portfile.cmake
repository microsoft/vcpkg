vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rbock/sqlpp11
    REF 085713d4d301aeb58e7d14f44cfac6ce35fe2e77 # 0.60
    SHA512 835536482def61c9978cda58507a7f5983b99765f69e7865cf5597b06075dc3e7ad4a3be0b2de2e44e4a4c3a6998115bf567ff586fb656cf5d95a0a7465fb2fe
    HEAD_REF master
    PATCHES
        ddl2cpp_path.patch
        fix-dependency.patch
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
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Sqlpp11 TARGET_PATH share/${PORT})

# Delete redundant and unnecessary directories
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib ${CURRENT_PACKAGES_DIR}/cmake ${CURRENT_PACKAGES_DIR}/include/date)

# Move python script from bin directory
file(COPY ${CURRENT_PACKAGES_DIR}/bin/sqlpp11-ddl2cpp DESTINATION ${CURRENT_PACKAGES_DIR}/scripts)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
