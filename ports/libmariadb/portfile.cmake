
if (EXISTS "${CURRENT_INSTALLED_DIR}/share/libmysql")
    message(FATAL_ERROR "FATAL ERROR: libmysql and libmariadb are incompatible.")
endif()

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MariaDB/mariadb-connector-c
    REF 8e9c3116105d9a998a60991b7f4ba910d454d4b1 # v3.1.7
    SHA512 b663effe7794d997c0589a9a20dab6b7359414612e60e3cb43e3fd0ddeae0391bcbc2d816cba4a7438602566ad6781cbf8e18b0062f1d37a2b2bd521af16033c
    HEAD_REF master
    PATCHES
            md.patch
            disable-test-build.patch
			fix-InstallPath.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
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

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

if(VCPKG_BUILD_TYPE STREQUAL "debug")
    # move headers
    file(RENAME
        ${CURRENT_PACKAGES_DIR}/debug/include
        ${CURRENT_PACKAGES_DIR}/include)
endif()

# remove plugin folder
file(REMOVE_RECURSE
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
