if (EXISTS "${CURRENT_INSTALLED_DIR}/share/libmysql")
    message(FATAL_ERROR "FATAL ERROR: libmysql and libmariadb are incompatible.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MariaDB/mariadb-connector-c
    REF a746c3af449a8754e78ad7971e59e79af7957cdb # v3.1.9
    SHA512 6f200b984b0642bd75dd8b1ca8f6b996c4b9236c4180255d15dee369a10b3b802c0e8e1942135aeb3c279f3087ff4b19096e5fef15935f4b76cf4fcb344d9133
    HEAD_REF master
    PATCHES
        md.patch
        disable-test-build.patch
        fix-InstallPath.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    zlib WITH_EXTERNAL_ZLIB
    openssl WITH_SSL
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DWITH_UNITTEST=OFF
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

file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
