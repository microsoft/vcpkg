if (EXISTS "${CURRENT_INSTALLED_DIR}/include/mysql/mysql.h")
    message(FATAL_ERROR "FATAL ERROR: ${PORT} and libmariadb are incompatible.")
endif()

if (VCPKG_TARGET_IS_LINUX)
    message(WARNING "${PORT} needs ncurses on LINUX, please install ncurses first.\nOn Debian/Ubuntu, package name is libncurses5-dev, on Redhat and derivates it is ncurses-devel.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mysql/mysql-server
    REF 7d10c82196c8e45554f27c00681474a9fb86d137 # 8.0.20
    SHA512 9f5e8cc254ea2a4cf76313287c7bb6fc693400810464dd2901e67d51ecb27f8916009464fd8aed8365c3038314b845b3d517db6e82ae5c7908612f0b3b72335f
    HEAD_REF master
    PATCHES
        ignore-boost-version.patch
        system-libs.patch
        rename-version.patch
        export-cmake-targets.patch
        004-added-limits-include.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/include/boost_1_70_0")

set(STACK_DIRECTION)
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(STACK_DIRECTION -DSTACK_DIRECTION=-1)
endif()

#Skip the version check for Visual Studio
if(VCPKG_TARGET_IS_WINDOWS)
    set(FORCE_UNSUPPORTED_COMPILER 1)
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static"  BUILD_STATIC_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static"  STATIC_CRT_LINKAGE)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWITHOUT_SERVER=ON
        -DWITH_UNIT_TESTS=OFF
        -DENABLED_PROFILING=OFF
        -DENABLE_TESTING=OFF
        -DWIX_DIR=OFF
        ${STACK_DIRECTION}
        -DIGNORE_BOOST_VERSION=ON
        -DWITH_SYSTEMD=OFF
        -DWITH_TEST_TRACE_PLUGIN=OFF
        -DMYSQL_MAINTAINER_MODE=OFF
        -DBUNDLE_RUNTIME_LIBRARIES=OFF
        -DDOWNLOAD_BOOST=OFF
        -DENABLE_DOWNLOADS=OFF
        -DWITH_NDB_TEST=OFF
        -DWITH_NDB_NODEJS_DEFAULT=OFF
        -DWITH_NDBAPI_EXAMPLES=OFF
        -DMYSQLX_ADDITIONAL_TESTS_ENABLE=OFF
        -DWITH_SSL=system
        -DWITH_ICU=system
        -DWITH_LIBEVENT=system
        -DWITH_LZ4=system
        -DWITH_ZLIB=system
        -DFORCE_UNSUPPORTED_COMPILER=${FORCE_UNSUPPORTED_COMPILER}
        -DINSTALL_STATIC_LIBRARIES=${BUILD_STATIC_LIBS}
        -DLINK_STATIC_RUNTIME_LIBRARIES=${STATIC_CRT_LINKAGE}
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)

list(APPEND MYSQL_TOOLS
    comp_err
    my_print_defaults
    mysql
    mysql_config_editor
    mysql_secure_installation
    mysql_ssl_rsa_setup
    mysqladmin
    mysqlbinlog
    mysqlcheck
    mysqldump
    mysqlimport
    mysqlpump
    mysqlshow
    mysqlslap
    mysqltest
    perror
    zlib_decompress
)

if (VCPKG_TARGET_IS_WINDOWS)
    list(APPEND MYSQL_TOOLS
        echo
    )
else()
    list(APPEND MYSQL_TOOLS
        mysql_config
    )
endif()

vcpkg_copy_tools(TOOL_NAMES ${MYSQL_TOOLS} AUTO_CLEAN)

file(RENAME "${CURRENT_PACKAGES_DIR}/share" "${CURRENT_PACKAGES_DIR}/${PORT}")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/debug/${PORT}")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/share")
file(RENAME "${CURRENT_PACKAGES_DIR}/${PORT}" "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(RENAME "${CURRENT_PACKAGES_DIR}/debug/${PORT}" "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}")

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-libmysql CONFIG_PATH share/${PORT}/unofficial-libmysql)

# switch mysql into /mysql
file(RENAME "${CURRENT_PACKAGES_DIR}/include" "${CURRENT_PACKAGES_DIR}/include2")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/include2" "${CURRENT_PACKAGES_DIR}/include/mysql")

## delete useless vcruntime/scripts/bin/msg file
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/docs"
    "${CURRENT_PACKAGES_DIR}/debug/docs"
    "${CURRENT_PACKAGES_DIR}/lib/debug"
    "${CURRENT_PACKAGES_DIR}/lib/plugin"
    "${CURRENT_PACKAGES_DIR}/lib/plugin/debug"
)

## remove misc files
file(REMOVE
    "${CURRENT_PACKAGES_DIR}/LICENSE"
    "${CURRENT_PACKAGES_DIR}/README"
    "${CURRENT_PACKAGES_DIR}/debug/LICENSE"
    "${CURRENT_PACKAGES_DIR}/debug/README"
)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mysql/mysql_com.h" "#include <mysql/udf_registration_types.h>" "#include \"mysql/udf_registration_types.h\"")
if (NOT VCPKG_TARGET_IS_WINDOWS)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/tools/libmysql/mysql_config" "${CURRENT_PACKAGES_DIR}" "`dirname $0`/../..")
endif()

file(INSTALL "${CURRENT_PORT_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# copy license
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
