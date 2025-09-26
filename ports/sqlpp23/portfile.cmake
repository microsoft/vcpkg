vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO rbock/sqlpp23
    REF ${VERSION}
    SHA512 6dd077289c8743d6aa1907642cbe255ebe93339cadf4aab6062b1c592f37c4ff1e7e62c5c3c5121f4550144411f514786858251680cf6fb3f2118e6d3f12ed7f
    HEAD_REF main
    PATCHES
        fix-findpackage.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        mysql BUILD_MYSQL_CONNECTOR
	mariadb BUILD_MARIADB_CONNECTOR
	postgres BUILD_POSTGRESQL_CONNECTOR
	sqlite3 BUILD_SQLITE3_CONNECTOR
	sqlcipher BUILD_SQLCIPHER_CONNECTOR
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
	-DBUILD_WITH_MODULES=OFF
	-DBUILD_TESTING=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
	CONFIG_PATH "lib/cmake/Sqlpp23/"
)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/CREDITS")
