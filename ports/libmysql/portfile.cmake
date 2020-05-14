vcpkg_fail_port_install(ON_TARGET "UWP" ON_ARCH "x86")

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
)

file(REMOVE_RECURSE ${SOURCE_PATH}/include/boost_1_70_0)

set(STACK_DIRECTION)
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(STACK_DIRECTION -DSTACK_DIRECTION=-1)
endif()

#Skip the version check for Visual Studio
if(VCPKG_TARGET_IS_WINDOWS)
    set(FORCE_UNSUPPORTED_COMPILER 1)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWITHOUT_SERVER=ON
        -DWITH_UNIT_TESTS=OFF
        -DENABLED_PROFILING=OFF
        -DWIX_DIR=OFF
        ${STACK_DIRECTION}
        -DIGNORE_BOOST_VERSION=ON
        -DWITH_SSL=system
        -DWITH_ICU=system
        -DWITH_LIBEVENT=system
        -DWITH_LZ4=system
        -DWITH_ZLIB=system
        -DFORCE_UNSUPPORTED_COMPILER=${FORCE_UNSUPPORTED_COMPILER}
)

vcpkg_install_cmake(ADD_BIN_TO_PATH)

# delete debug headers
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include)

# switch mysql into /mysql
file(RENAME ${CURRENT_PACKAGES_DIR}/include ${CURRENT_PACKAGES_DIR}/include2)
file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/include)
file(RENAME ${CURRENT_PACKAGES_DIR}/include2 ${CURRENT_PACKAGES_DIR}/include/mysql)

## delete useless vcruntime/scripts/bin/msg file
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/share
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/bin
    ${CURRENT_PACKAGES_DIR}/debug/bin
    ${CURRENT_PACKAGES_DIR}/docs
    ${CURRENT_PACKAGES_DIR}/debug/docs
    ${CURRENT_PACKAGES_DIR}/lib/debug
    ${CURRENT_PACKAGES_DIR}/lib/plugin/debug)

## remove misc files
file(REMOVE
    ${CURRENT_PACKAGES_DIR}/LICENSE
    ${CURRENT_PACKAGES_DIR}/README
    ${CURRENT_PACKAGES_DIR}/debug/LICENSE
    ${CURRENT_PACKAGES_DIR}/debug/README)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE
        ${CURRENT_PACKAGES_DIR}/lib/libmysql.lib
        ${CURRENT_PACKAGES_DIR}/lib/libmysql.dll
        ${CURRENT_PACKAGES_DIR}/lib/libmysql.pdb
        ${CURRENT_PACKAGES_DIR}/debug/lib/libmysql.lib
        ${CURRENT_PACKAGES_DIR}/debug/lib/libmysql.dll
        ${CURRENT_PACKAGES_DIR}/debug/lib/libmysql.pdb)
else()
    file(REMOVE
        ${CURRENT_PACKAGES_DIR}/lib/mysqlclient.lib
        ${CURRENT_PACKAGES_DIR}/debug/lib/mysqlclient.lib)

    # correct the dll directory
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
        file (RENAME ${CURRENT_PACKAGES_DIR}/lib/libmysql.dll ${CURRENT_PACKAGES_DIR}/bin/libmysql.dll)
        file (RENAME ${CURRENT_PACKAGES_DIR}/lib/libmysql.pdb ${CURRENT_PACKAGES_DIR}/bin/libmysql.pdb)
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
        file (RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libmysql.dll ${CURRENT_PACKAGES_DIR}/debug/bin/libmysql.dll)
        file (RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libmysql.pdb ${CURRENT_PACKAGES_DIR}/debug/bin/libmysql.pdb)
    endif()
endif()

file(READ ${CURRENT_PACKAGES_DIR}/include/mysql/mysql_com.h _contents)
string(REPLACE "#include <mysql/udf_registration_types.h>" "#include \"mysql/udf_registration_types.h\"" _contents "${_contents}")
file(WRITE ${CURRENT_PACKAGES_DIR}/include/mysql/mysql_com.h "${_contents}")

# copy license
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
