vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SOCI/soci
    REF "v${VERSION}"
    SHA512 0553fb7856c77158b229c33fb7a14402f9d740825db5b0c0c4cbbbc2596faa56b099f7e13bece5af506311c393e6fcb4e8b448522d15bba57c6dd0d23e6467c1
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SOCI_DYNAMIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        boost       WITH_BOOST
        boost       CMAKE_REQUIRE_FIND_PACKAGE_Boost
        empty       SOCI_EMPTY
        mysql       SOCI_MYSQL
        odbc        SOCI_ODBC
        postgresql  SOCI_POSTGRESQL
        sqlite3     SOCI_SQLITE3
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSOCI_SHARED=${SOCI_DYNAMIC}
        -DSOCI_TESTS=OFF
        -DSOCI_INSTALL=ON
        -DSOCI_FMT_BUILTIN=OFF
        # SOCI components whose backends are not yet available through vcpkg
        -DSOCI_DB2=OFF
        -DSOCI_FIREBIRD=OFF
        -DSOCI_ORACLE=OFF
        ${options}
    MAYBE_UNUSED_VARIABLES
        CMAKE_REQUIRE_FIND_PACKAGE_Boost
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/soci-${VERSION})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    # Needed to be consumable without CMake (which sets the macro automatically)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/soci/soci-platform.h" "ifdef SOCI_DLL" "if 1")
endif()

file(READ "${CURRENT_PORT_DIR}/usage" usage)
set(backends ${FEATURES})
list(REMOVE_ITEM backends core boost)
if(backends STREQUAL "")
    string(APPEND usage "
This SOCI build doesn't include any backend and may not be useful.
")
else()
    string(APPEND usage "
    # This version of SOCI was built with support for these components:
    # - core
")
endif()
foreach(backend IN LISTS backends)
    string(APPEND usage "    # - ${backend}
")
endforeach()
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" "${usage}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
