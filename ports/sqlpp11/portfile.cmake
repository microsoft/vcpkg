vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rbock/sqlpp11
    REF 648183fd64070185019f9237481b888173abfaf2 # 2022-09-14
    SHA512 0429c5972ef111a41422ebd3ca259bc7f2cca126b0abd526270e7c8553fbc9d22ee584c526340a7f3c667143a16b961c222687806641b6ddfe9a258bd5e1ccc8
    HEAD_REF master
    PATCHES
        ddl2cpp_path.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        sqlite3  BUILD_SQLITE3_CONNECTOR
        mariadb  BUILD_MARIADB_CONNECTOR
        mysql    BUILD_MYSQL_CONNECTOR
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
