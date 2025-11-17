set(VCPKG_BUILD_TYPE release)  # header-only lib

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rbock/sqlpp11
    REF ${VERSION}
    SHA512 8227bc613c9ca279fef8549472da518b81151d1d6e43600617017ebaf359a7c8d0bb7a17c96db232754fc7bc002ad44c4392826857710c18c65e2eb728a97dd5
    HEAD_REF main
    PATCHES
        ddl2cpp_path.patch
        dependencies.diff
        fix-miss-header.patch
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        sqlite3    BUILD_SQLITE3_CONNECTOR
        mariadb    BUILD_MARIADB_CONNECTOR
        mysql      BUILD_MYSQL_CONNECTOR
        postgresql BUILD_POSTGRESQL_CONNECTOR
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING:BOOL=OFF
        -DSQLPP11_INSTALL_CMAKEDIR=share/${PORT}
        -DUSE_SYSTEM_DATE:BOOL=ON
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

set(usage "sqlpp11 provides CMake targets:\n")
if(FEATURES STREQUAL "core")
    set(usage "This build of sqlpp11 doesn't include any connector.\n(Available via features: sqlite3, mariadb, mysql, postgresql.)\n")
endif()
foreach(component IN ITEMS SQLite3 SQLCipher MySQL MariaDB PostgreSQL)
    string(TOLOWER "${component}" lib)
    if("${lib}" IN_LIST FEATURES)
        string(APPEND usage "\n  find_package(Sqlpp11 CONFIG REQUIRED COMPONENTS ${component})\n  target_link_libraries(main PRIVATE sqlpp11::${lib})\n")
    endif()
endforeach()
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" "${usage}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
