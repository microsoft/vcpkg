vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO getml/sqlgen
    REF "v${VERSION}"
    SHA512 a2853d6bcd31d2e9fe7c928d9f1c668ff8fcc2c93bd38c82e0bd4b88826f102443274fab0aee209c11145d2ac44fcbd25303fa7e34e82929d18264643bd16514 
    HEAD_REF main
)

if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SQLGEN_BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        duckdb              SQLGEN_DUCKDB
        mariadb             SQLGEN_MYSQL
        postgres            SQLGEN_POSTGRES
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        ${FEATURE_OPTIONS}
        -DSQLGEN_BUILD_TESTS=OFF
        -DSQLGEN_SQLITE3=ON
        -DSQLGEN_BUILD_SHARED=${SQLGEN_BUILD_SHARED}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
    CONFIG_PATH "lib/cmake/${PORT}"
)

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)
