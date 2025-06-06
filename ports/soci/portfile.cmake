vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO SOCI/soci
    REF "v${VERSION}"
    SHA512 96571776d7fcb814c2625ade92f1d5bbcbee2a654eb38a098c23d12d01e66ab2900fc82fdb2f1a37679f0091009f9c6880c80d939730c1bd67f3285418144eba
    HEAD_REF master
)
file(REMOVE
    "${SOURCE_PATH}/cmake/modules/FindPostgreSQL.cmake"
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SOCI_DYNAMIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SOCI_STATIC)

vcpkg_check_features(OUT_FEATURE_OPTIONS options
    FEATURES
        boost       WITH_BOOST
        boost       CMAKE_REQUIRE_FIND_PACKAGE_Boost
        empty       SOCI_EMPTY
        mysql       SOCI_MYSQL
        odbc        SOCI_ODBC
        odbc        CMAKE_REQUIRE_FIND_PACKAGE_ODBC
        postgresql  SOCI_POSTGRESQL
        sqlite3     SOCI_SQLITE3
    INVERTED_FEATURES
        core        SOCI_DB2
        core        SOCI_FIREBIRD
        core        SOCI_ORACLE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSOCI_CXX11=ON
        -DSOCI_SHARED=${SOCI_DYNAMIC}
        -DSOCI_STATIC=${SOCI_STATIC}
        -DSOCI_TESTS=OFF
        ${options}
    MAYBE_UNUSED_VARIABLES
        CMAKE_REQUIRE_FIND_PACKAGE_Boost
        CMAKE_REQUIRE_FIND_PACKAGE_ODBC
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/soci-${VERSION})

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/soci/soci-platform.h" "ifdef SOCI_DLL" "if 1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(READ "${CURRENT_PORT_DIR}/usage" usage)
set(backends ${FEATURES})
list(REMOVE_ITEM backends core boost)
if(backends STREQUAL "")
    string(APPEND usage "
This soci build doesn't include any backend and may not be useful.
")
endif()
foreach(backend IN LISTS backends)
    string(APPEND usage "
    # Using the ${backend} backend directly
    target_link_libraries(main PRIVATE $<IF:$<TARGET_EXISTS:SOCI::soci_${backend}>,SOCI::soci_${backend},SOCI::soci_${backend}_static>)
")
endforeach()
file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" "${usage}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE_1_0.txt")
