if (EXISTS "${CURRENT_INSTALLED_DIR}/include/mysql/mysql.h")
    message(FATAL_ERROR "FATAL ERROR: ${PORT} and libmariadb are incompatible.")
endif()

if(NOT VCPKG_TARGET_IS_WINDOWS)
    message(WARNING "'autoconf-archive' must be installed via your system package manager (brew, apt, etc.).")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mysql/mysql-server
    REF mysql-${VERSION}
    SHA512 8b9f15b301b158e6ffc99dd916b9062968d36f6bdd7b898636fa61badfbe68f7328d4a39fa3b8b3ebef180d3aec1aee353bd2dac9ef1594e5772291390e17ac0
    HEAD_REF master
    PATCHES
        ignore-boost-version.patch
        system-libs.patch
        export-cmake-targets.patch
        Add-target-include-directories.patch
        homebrew.patch
        fix_dup_symbols.patch
)

file(REMOVE_RECURSE "${SOURCE_PATH}/include/boost_1_70_0")

set(STACK_DIRECTION "")
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(STACK_DIRECTION -DSTACK_DIRECTION=-1)
endif()

#Skip the version check for Visual Studio
set(FORCE_UNSUPPORTED_COMPILER "")
if(VCPKG_TARGET_IS_WINDOWS)
    set(FORCE_UNSUPPORTED_COMPILER 1)
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static"  BUILD_STATIC_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static"  STATIC_CRT_LINKAGE)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWITHOUT_SERVER=ON
        -DWITH_BUILD_ID=OFF
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
        -DWITH_SSL=system
        -DWITH_ICU=system
        -DWITH_LIBEVENT=system
        -DWITH_LZ4=system
        -DWITH_ZLIB=system
        -DFORCE_UNSUPPORTED_COMPILER=${FORCE_UNSUPPORTED_COMPILER}
        -DINSTALL_STATIC_LIBRARIES=${BUILD_STATIC_LIBS}
        -DLINK_STATIC_RUNTIME_LIBRARIES=${STATIC_CRT_LINKAGE}
    MAYBE_UNUSED_VARIABLES
        BUNDLE_RUNTIME_LIBRARIES # only on windows
        LINK_STATIC_RUNTIME_LIBRARIES # only on windows
        WIX_DIR # only on windows
        WITH_BUILD_ID # only on windows
)

vcpkg_cmake_install(ADD_BIN_TO_PATH)

list(APPEND MYSQL_TOOLS
    comp_err
    my_print_defaults
    mysql
    mysql_config_editor
    mysql_migrate_keyring
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
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/share")
file(RENAME "${CURRENT_PACKAGES_DIR}/${PORT}" "${CURRENT_PACKAGES_DIR}/share/${PORT}")

if(NOT VCPKG_BUILD_TYPE)
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/share" "${CURRENT_PACKAGES_DIR}/debug/${PORT}")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/debug/share")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/${PORT}" "${CURRENT_PACKAGES_DIR}/debug/share/${PORT}")
endif()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-libmysql CONFIG_PATH share/${PORT}/unofficial-libmysql)

# switch mysql into /mysql
file(RENAME "${CURRENT_PACKAGES_DIR}/include" "${CURRENT_PACKAGES_DIR}/include2")
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(RENAME "${CURRENT_PACKAGES_DIR}/include2" "${CURRENT_PACKAGES_DIR}/include/mysql")

## delete useless vcruntime/scripts/bin/msg file
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/debug/man"
    "${CURRENT_PACKAGES_DIR}/docs"
    "${CURRENT_PACKAGES_DIR}/debug/docs"
    "${CURRENT_PACKAGES_DIR}/lib/debug"
    "${CURRENT_PACKAGES_DIR}/lib/plugin"
    "${CURRENT_PACKAGES_DIR}/debug/lib/plugin"
)

# delete dynamic dll on static build
if (BUILD_STATIC_LIBS)
    # libmysql.dll
    file(REMOVE_RECURSE 
        "${CURRENT_PACKAGES_DIR}/bin" 
        "${CURRENT_PACKAGES_DIR}/debug/bin"
    )
    file(REMOVE
        "${CURRENT_PACKAGES_DIR}/lib/libmysql.lib"
        "${CURRENT_PACKAGES_DIR}/debug/lib/libmysql.lib"
        "${CURRENT_PACKAGES_DIR}/lib/libmysql.pdb"
        "${CURRENT_PACKAGES_DIR}/debug/lib/libmysql.pdb"
    )
endif()

## remove misc files
file(REMOVE
    "${CURRENT_PACKAGES_DIR}/LICENSE"
    "${CURRENT_PACKAGES_DIR}/README"
    "${CURRENT_PACKAGES_DIR}/debug/LICENSE"
    "${CURRENT_PACKAGES_DIR}/debug/README"
)

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/mysql/mysql_com.h" "#include <mysql/udf_registration_types.h>" "#include \"mysql/udf_registration_types.h\"")
if (NOT VCPKG_TARGET_IS_WINDOWS)
    set(MYSQL_CONFIG_FILE "${CURRENT_PACKAGES_DIR}/tools/libmysql/mysql_config")
    vcpkg_replace_string(${MYSQL_CONFIG_FILE} "/bin/mysql_.*config" "/tools/libmysql/mysql_.*config")  # try to get correct $basedir
    vcpkg_replace_string(${MYSQL_CONFIG_FILE} "${CURRENT_PACKAGES_DIR}" "$basedir")  # use $basedir to format paths
    vcpkg_replace_string(${MYSQL_CONFIG_FILE} "-l\$\<\$\<CONFIG:DEBUG\>:${CURRENT_INSTALLED_DIR}/debug/lib/libz.a> " "")  # remove debug version of libz
    vcpkg_replace_string(${MYSQL_CONFIG_FILE} 
        "\$\<\$\<NOT:\$\<CONFIG:DEBUG\>\>:${CURRENT_INSTALLED_DIR}" 
        "`dirname $0`/../../../../installed/${TARGET_TRIPLET}")  # correct path for release version of libz
    vcpkg_replace_string(${MYSQL_CONFIG_FILE} "\> -l" " -l") # trailing > tag for previous item
endif()

file(INSTALL "${CURRENT_PORT_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

# copy license
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
