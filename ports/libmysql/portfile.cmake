if (EXISTS "${CURRENT_INSTALLED_DIR}/include/mysql/mysql.h")
    message(FATAL_ERROR "FATAL ERROR: libmysql and libmariadb are incompatible.")
endif()

if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "libmysql cannot currently be cross-compiled for UWP")
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" AND NOT CMAKE_SYSTEM_NAME OR CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    message(FATAL_ERROR "Oracle has dropped support in libmysql for 32-bit Windows.")
endif()

if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Linux")
    message(WARNING "libmysql needs ncurses on LINUX, please install ncurses first.\nOn Debian/Ubuntu, package name is libncurses5-dev, on Redhat and derivates it is ncurses-devel.")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mysql/mysql-server
    REF mysql-8.0.4
    SHA512 8d9129e7670e88df14238299052a5fe6d4f3e40bf27ef7a3ca8f4f91fb40507b13463e9bd24435b34e5d06c5d056dfb259fb04e77cc251b188eea734db5642be
    HEAD_REF master
    PATCHES
        ignore-boost-version.patch
        system-libs.patch
        linux_libmysql.patch
)

file(REMOVE_RECURSE ${SOURCE_PATH}/include/boost_1_65_0)

set(STACK_DIRECTION)
if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "x64")
    set(STACK_DIRECTION -DSTACK_DIRECTION=-1)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DWITHOUT_SERVER=ON
        -DWITH_UNIT_TESTS=OFF
        -DENABLED_PROFILING=OFF
        -DWIX_DIR=OFF
        -DHAVE_LLVM_LIBCPP_EXITCODE=1
        ${STACK_DIRECTION}
        -DWINDOWS_RUNTIME_MD=ON # Note: this disables _replacement_ of /MD with /MT. If /MT is specified, it will be preserved.
        -DIGNORE_BOOST_VERSION=ON
        -DWITH_SSL=system
        -DWITH_ICU=system
        -DWITH_LIBEVENT=system
        -DWITH_LZMA=system
        -DWITH_LZ4=system
        -DWITH_ZLIB=system
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
    ${CURRENT_PACKAGES_DIR}/lib/debug)

# remove misc files
file(REMOVE
    ${CURRENT_PACKAGES_DIR}/LICENSE
    ${CURRENT_PACKAGES_DIR}/README
    ${CURRENT_PACKAGES_DIR}/debug/LICENSE
    ${CURRENT_PACKAGES_DIR}/debug/README)

# remove not-related libs
file (REMOVE
    ${CURRENT_PACKAGES_DIR}/lib/mysqlservices.lib
    ${CURRENT_PACKAGES_DIR}/debug/lib/mysqlservices.lib)

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
file(COPY ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/libmysql)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libmysql/LICENSE ${CURRENT_PACKAGES_DIR}/share/libmysql/copyright)
