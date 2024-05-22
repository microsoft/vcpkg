vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rbock/sqlpp11
    REF ${VERSION}
    SHA512 7b48f66e2e229ed046a5b5033acc1be36b0c2790773a81ce9c65fce4a85379d61e87dd0ff214eb4126ce87fe6cf2f314b7e6c54256b600d15d8352d74a8fac0d
    HEAD_REF master
    PATCHES
        ddl2cpp_path.patch
        fix_link_sqlite3.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        sqlite3    BUILD_SQLITE3_CONNECTOR
        mariadb    BUILD_MARIADB_CONNECTOR
        mysql      BUILD_MYSQL_CONNECTOR
        postgresql BUILD_POSTGRESQL_CONNECTOR
)

# Use sqlpp11's own build process
vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING:BOOL=OFF
        # Use vcpkg as source for the date library
        -DUSE_SYSTEM_DATE:BOOL=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

# Move CMake config files to the right place
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Sqlpp11)

# Delete redundant and unnecessary directories
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/cmake" "${CURRENT_PACKAGES_DIR}/include/date")

# Move python script from bin directory
file(COPY "${CURRENT_PACKAGES_DIR}/bin/sqlpp11-ddl2cpp" DESTINATION "${CURRENT_PACKAGES_DIR}/scripts")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin/")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
