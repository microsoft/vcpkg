
if (EXISTS "${CURRENT_INSTALLED_DIR}/share/libmysql")
    message(FATAL_ERROR "FATAL ERROR: libmysql and libmariadb are incompatible.")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MariaDB/mariadb-connector-c
    REF c098613d289ed88fc53286e98add28ae9f2d8b46
    SHA512 dfddc3e0ede587fcf27339a285e9e97dfd4c377a712424b5138686ab131458d6d252218e2d1eda3ab73c5a41af84a2d5349a93213adab22ac2d889912c960270
    HEAD_REF master
    PATCHES
            md.patch
            disable-test-build.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DWITH_UNITTEST=OFF
        -DWITH_SSL=OFF
        -DWITH_CURL=OFF
)

vcpkg_install_cmake()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    # remove debug header
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
endif()

if(VCPKG_BUILD_TYPE STREQUAL "debug")
    # move headers
    file(RENAME
        ${CURRENT_PACKAGES_DIR}/debug/include
        ${CURRENT_PACKAGES_DIR}/include)
endif()

# fix libmariadb lib & dll directory.
if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/lib/mariadb/mariadbclient.lib
            ${CURRENT_PACKAGES_DIR}/lib/mariadbclient.lib)
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/debug/lib/mariadb/mariadbclient.lib
            ${CURRENT_PACKAGES_DIR}/debug/lib/mariadbclient.lib)
    endif()
else()
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/lib/mariadb/libmariadb.dll
            ${CURRENT_PACKAGES_DIR}/bin/libmariadb.dll)
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/lib/mariadb/libmariadb.lib
            ${CURRENT_PACKAGES_DIR}/lib/libmariadb.lib)
    endif()

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/debug/lib/mariadb/libmariadb.dll
            ${CURRENT_PACKAGES_DIR}/debug/bin/libmariadb.dll)
        file(RENAME
            ${CURRENT_PACKAGES_DIR}/debug/lib/mariadb/libmariadb.lib
            ${CURRENT_PACKAGES_DIR}/debug/lib/libmariadb.lib)
    endif()
endif()

# remove plugin folder
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/lib/plugin
    ${CURRENT_PACKAGES_DIR}/debug/lib/plugin
    ${CURRENT_PACKAGES_DIR}/lib/mariadb
    ${CURRENT_PACKAGES_DIR}/debug/lib/mariadb)

# copy & remove header files
file(REMOVE
    ${CURRENT_PACKAGES_DIR}/include/mariadb/my_config.h.in
    ${CURRENT_PACKAGES_DIR}/include/mariadb/mysql_version.h.in
    ${CURRENT_PACKAGES_DIR}/include/mariadb/CMakeLists.txt
    ${CURRENT_PACKAGES_DIR}/include/mariadb/Makefile.am)
file(RENAME
    ${CURRENT_PACKAGES_DIR}/include/mariadb
    ${CURRENT_PACKAGES_DIR}/include/mysql)

# copy license file
file(COPY ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/libmariadb)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libmariadb/COPYING.LIB ${CURRENT_PACKAGES_DIR}/share/libmariadb/copyright)
