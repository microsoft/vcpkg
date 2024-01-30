if(EXISTS "${CURRENT_INSTALLED_DIR}/share/libmysql")
    message(FATAL_ERROR "FATAL ERROR: libmysql and libmariadb are incompatible.")
endif()

if("openssl" IN_LIST FEATURES AND "schannel" IN_LIST FEATURES)
    message(FATAL_ERROR "Only one SSL backend must be selected.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mariadb-corporation/mariadb-connector-c
    REF 5e94e7c27ffad7e76665b1333a67975316b9c3c2 # v3.3.1
    SHA512 0f740f88f64037990bf9d4593574b147ee02adb1fbbeb03c0dec745f0ee27d7cf03417dd09546ab70e16b4465622b8567864dbb243de0a3a7ffaebe313f7c231
    HEAD_REF 3.3
    PATCHES
        md.patch
        disable-test-build.patch
        fix-InstallPath.patch
        fix-iconv.patch
        pkgconfig.patch
        fix-openssl.patch
        fix-CMakeLists.patch
        zstd.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        iconv            WITH_ICONV
        mariadbclient    VCPKG_MARIADBCLIENT
        zstd             WITH_ZSTD
)

if("openssl" IN_LIST FEATURES)
    set(WITH_SSL OPENSSL)
elseif("schannel" IN_LIST FEATURES)
    set(WITH_SSL ON)
else()
    set(WITH_SSL OFF)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DINSTALL_INCLUDEDIR=include/mysql # legacy port decisiong
        -DINSTALL_LIBDIR=lib
        -DINSTALL_PLUGINDIR=plugins/${PORT}
        -DWITH_UNIT_TESTS=OFF
        -DWITH_CURL=OFF
        -DWITH_EXTERNAL_ZLIB=ON
        -DWITH_SSL=${WITH_SSL}
        -DREMOTEIO_PLUGIN_TYPE=OFF
        -DAUTH_GSSAPI_PLUGIN_TYPE=OFF
        -DWITH_ZSTD=${WITH_ZSTD}
    MAYBE_UNUSED_VARIABLES
        AUTH_GSSAPI_PLUGIN_TYPE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-libmariadb)

if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libmariadb.pc" " -lmariadb" " -llibmariadb")
    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libmariadb.pc" " -lmariadb" " -llibmariadb")
    endif()
endif()

vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING.LIB" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
