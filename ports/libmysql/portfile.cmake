if (EXISTS "${CURRENT_INSTALLED_DIR}/include/mysql/mysql.h")
    message(FATAL_ERROR "FATAL ERROR: libmysql and libmariadb are incompatible.")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mysql/mysql-server
    REF mysql-5.7.17
    SHA512 31488972e08a6b83f88e6e3f7923aca91e01eac702f4942fdae92e13f66d92ac86c24dfe7a65a001db836c900147d1c3871b36af8cbb281a0e6c555617cac12c
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/boost_and_build.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DWITHOUT_SERVER=ON
        -DWITH_UNIT_TESTS=OFF
        -DENABLED_PROFILING=OFF
        -DWIX_DIR=OFF
        -DWINDOWS_RUNTIME_MD=ON # Note: this disables _replacement_ of /MD with /MT. If /MT is specified, it will be preserved.
)

vcpkg_install_cmake()

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
    ${CURRENT_PACKAGES_DIR}/COPYING
    ${CURRENT_PACKAGES_DIR}/README
    ${CURRENT_PACKAGES_DIR}/debug/COPYING
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
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/bin)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/bin)
    file (RENAME ${CURRENT_PACKAGES_DIR}/lib/libmysql.dll ${CURRENT_PACKAGES_DIR}/bin/libmysql.dll)
    file (RENAME ${CURRENT_PACKAGES_DIR}/lib/libmysql.pdb ${CURRENT_PACKAGES_DIR}/bin/libmysql.pdb)
    file (RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libmysql.dll ${CURRENT_PACKAGES_DIR}/debug/bin/libmysql.dll)
    file (RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libmysql.pdb ${CURRENT_PACKAGES_DIR}/debug/bin/libmysql.pdb)
endif()

# copy license
file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libmysql)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libmysql/COPYING ${CURRENT_PACKAGES_DIR}/share/libmysql/copyright)