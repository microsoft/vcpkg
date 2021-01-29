if (EXISTS "${CURRENT_INSTALLED_DIR}/share/libmysql")
    message(FATAL_ERROR "FATAL ERROR: libmysql and libmariadb are incompatible.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO MariaDB/mariadb-connector-c
    REF 159540fe8c8f30b281748fe8a1b79e8b17993a67 # v3.1.10
    SHA512 3e154f5dc4b5051607c7ebc0691a50c0699d60e4414660cf8f65689081ff78ef6b135667761ba8ac4163b469a3b55158c6b48c6fc0a0cc09381452aad157e4ad
    HEAD_REF 3.1
    PATCHES
        arm64.patch
        md.patch
        disable-test-build.patch
        fix-InstallPath.patch
        fix-iconv.patch
        export-cmake-targets.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    zlib WITH_EXTERNAL_ZLIB
    iconv WITH_ICONV
)

if("openssl" IN_LIST FEATURES)
	set(WITH_SSL OPENSSL)
else()
	set(WITH_SSL OFF)
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        -DWITH_UNITTEST=OFF
        -DWITH_CURL=OFF
        -DWITH_SSL=${WITH_SSL}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/unofficial-libmariadb TARGET_PATH share/unofficial-libmariadb)

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
file(INSTALL ${SOURCE_PATH}/COPYING.LIB DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)