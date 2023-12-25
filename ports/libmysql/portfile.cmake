if (EXISTS "${CURRENT_INSTALLED_DIR}/include/mysql/mysql.h")
    message(FATAL_ERROR "FATAL ERROR: ${PORT} and libmariadb are incompatible.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mysql/mysql-server
    REF mysql-${VERSION}
    SHA512 5df45c1ce1e2c620856b9274666cf56738d6a0308c33c9c96583b494c987fb0e862e676301109b9e4732070d54e6086596a62ad342f35adc59ca9f749e37b561
    HEAD_REF master
    PATCHES
        dependencies.patch
        install-exports.patch
        fix_dup_symbols.patch
        cross-build.patch
)
file(GLOB third_party "${SOURCE_PATH}/extra/*" "${SOURCE_PATH}/include/boost_1_70_0")
list(REMOVE_ITEM third_party "${SOURCE_PATH}/extra/libedit")
file(REMOVE_RECURSE ${third_party})

#Skip the version check for Visual Studio
set(FORCE_UNSUPPORTED_COMPILER "")
if(VCPKG_TARGET_IS_WINDOWS)
    set(FORCE_UNSUPPORTED_COMPILER 1)
endif()

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static"  BUILD_STATIC_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static"  STATIC_CRT_LINKAGE)

set(cross_options "")
if(VCPKG_CROSSCOMPILING)
    list(APPEND cross_options
        -DCMAKE_CROSSCOMPILING=1
        -DVCPKG_HOST_TRIPLET=${HOST_TRIPLET}
        # required, skip try_run
        -DHAVE_RAPIDJSON_WITH_STD_REGEX=1
    )
    if(NOT VCPKG_TARGET_IS_WINDOWS)
        list(APPEND cross_options
            # optimistic, skip try_run
            -DHAVE_CLOCK_GETTIME=1
            -DHAVE_CLOCK_REALTIME=1
            # pessimistic, skip try_run
            -DHAVE_C_FLOATING_POINT_FUSED_MADD=1
            -DHAVE_CXX_FLOATING_POINT_FUSED_MADD=1
            -DHAVE_SETNS=0
        )
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${cross_options}
        -DINSTALL_INCLUDEDIR=include/mysql
        -DINSTALL_DOCDIR=share/${PORT}/doc
        -DINSTALL_MANDIR=share/${PORT}/doc
        -DINSTALL_INFODIR=share/${PORT}/doc
        -DINSTALL_DOCREADMEDIR=share/${PORT}
        -DINSTALL_SHAREDIR=share
        -DINSTALL_MYSQLSHAREDIR=share/${PORT}
        -DWITHOUT_SERVER=ON
        -DWITH_BUILD_ID=OFF
        -DWITH_UNIT_TESTS=OFF
        -DENABLED_PROFILING=OFF
        -DWIX_DIR=OFF
        -DIGNORE_BOOST_VERSION=ON
        -DWITH_TEST_TRACE_PLUGIN=OFF
        -DMYSQL_MAINTAINER_MODE=OFF
        -DBUNDLE_RUNTIME_LIBRARIES=OFF
        -DDOWNLOAD_BOOST=OFF
        -DWITH_CURL=none
        -DWITH_EDITLINE=bundled # not in vcpkg
        -DWITH_LZ4=system
        -DWITH_RAPIDJSON=system
        -DWITH_SSL=system
        -DWITH_SYSTEMD=OFF
        -DWITH_ZLIB=system
        -DWITH_ZSTD=system
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
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-libmysql)
vcpkg_fixup_pkgconfig()

set(MYSQL_TOOLS
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
if (NOT VCPKG_CROSSCOMPILING)
    list(APPEND MYSQL_TOOLS
        comp_err
    )
endif()
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

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/lib/debug"
)

if (NOT VCPKG_TARGET_IS_WINDOWS)
    set(MYSQL_CONFIG_FILE "${CURRENT_PACKAGES_DIR}/tools/libmysql/mysql_config")
    vcpkg_replace_string("${MYSQL_CONFIG_FILE}" "/bin/mysql_.*config" "/tools/libmysql/mysql_.*config")
    vcpkg_replace_string("${MYSQL_CONFIG_FILE}" "'${CURRENT_PACKAGES_DIR}" "\"\$basedir\"\'")
endif()

file(INSTALL "${CURRENT_PORT_DIR}/libmysql-config.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

set(libedit_copying "${SOURCE_PATH}/COPYING for libedit")
file(COPY_FILE "${SOURCE_PATH}/extra/libedit/libedit-20210910-3.1/COPYING" "${libedit_copying}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${libedit_copying}")
