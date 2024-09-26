set(VCPKG_BUILD_TYPE release)  # header-only lib

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rbock/sqlpp11
    REF ${VERSION}
    SHA512 7b48f66e2e229ed046a5b5033acc1be36b0c2790773a81ce9c65fce4a85379d61e87dd0ff214eb4126ce87fe6cf2f314b7e6c54256b600d15d8352d74a8fac0d
    HEAD_REF main
    PATCHES
        ddl2cpp_path.patch
        dependencies.diff
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
