vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rbock/sqlpp11
    REF 0.59
    SHA512 9da05e7a5163200040205b9740d6bf4ad1faa94b2bf031c16d896865b3f10e0fe95a0532a2c2e89adc051250a7f76c550a239916fdd700828d4fb1da566a4fe3
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
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Sqlpp11 TARGET_PATH share/${PORT})

# Delete redundant and unnecessary directories
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug ${CURRENT_PACKAGES_DIR}/lib)

# Move python script from bin directory
file(COPY ${CURRENT_PACKAGES_DIR}/bin/sqlpp11-ddl2cpp DESTINATION ${CURRENT_PACKAGES_DIR}/scripts)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin/)

# Handle copyright
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
