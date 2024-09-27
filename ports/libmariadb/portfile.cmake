if(EXISTS "${CURRENT_INSTALLED_DIR}/share/libmysql")
    message(FATAL_ERROR "FATAL ERROR: libmysql and libmariadb are incompatible.")
endif()

if("openssl" IN_LIST FEATURES AND "schannel" IN_LIST FEATURES)
    message(FATAL_ERROR "Only one SSL backend must be selected.")
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mariadb-corporation/mariadb-connector-c
    REF v${VERSION}
    SHA512 396ce2a36937d49ec96eb239312118c736f46383d2906b7142d9695e795f310af28255d8827cc98ad76ae4e6d5a22faf1188b7dd286791e3c85f22c96d0114b3
    HEAD_REF 3.4
    PATCHES
        compiler-flags.diff
        dependencies.diff
        disable-mariadb_config.diff
        library-linkage.diff
        cmake-export.diff
        no-abs-path.diff
        ushort-check.diff
)
file(REMOVE_RECURSE
    "${SOURCE_PATH}/cmake/FindIconv.cmake"
    "${SOURCE_PATH}/external/zlib"
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        iconv            WITH_ICONV
        zstd             WITH_ZSTD
)

string(TOUPPER "${VCPKG_LIBRARY_LINKAGE}" plugin_type)

set(zstd_plugin_type OFF)
if("zstd" IN_LIST FEATURES)
    set(zstd_plugin_type ${plugin_type})
endif()

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
        -DCMAKE_POLICY_DEFAULT_CMP0153=OLD
        -DINSTALL_INCLUDEDIR=include/mysql # legacy port decision
        -DINSTALL_LIBDIR=lib
        -DINSTALL_PLUGINDIR=plugins/${PORT}
        -DWITH_CURL=OFF
        -DWITH_EXTERNAL_ZLIB=ON
        -DWITH_SSL=${WITH_SSL}
        -DWITH_UNIT_TESTS=OFF
        # plugins/auth
        -DCLIENT_PLUGIN_AUTH_GSSAPI_CLIENT=OFF
        -DCLIENT_PLUGIN_CACHING_SHA2_PASSWORD=${plugin_type}
        -DCLIENT_PLUGIN_CLIENT_ED25519=DYNAMIC # want ${plugin_type}, but STATIC fails
        -DCLIENT_PLUGIN_DIALOG=${plugin_type}
        -DCLIENT_PLUGIN_PARSEC=OFF
        -DCLIENT_PLUGIN_MYSQL_CLEAR_PASSWORD=${plugin_type}
        -DCLIENT_PLUGIN_MYSQL_OLD_PASSWORD=OFF
        -DCLIENT_PLUGIN_SHA256_PASSWORD=${plugin_type}
        # plugins/compress 
        -DCLIENT_PLUGIN_ZSTD=${zstd_plugin_type}
        # don't add system include dirs
        -DAUTH_GSSAPI_PLUGIN_TYPE=OFF
        -DREMOTEIO_PLUGIN_TYPE=OFF 
    MAYBE_UNUSED_VARIABLES
        AUTH_GSSAPI_PLUGIN_TYPE
        CLIENT_PLUGIN_AUTH_GSSAPI_CLIENT
        CLIENT_PLUGIN_PARSEC
        CLIENT_PLUGIN_ZSTD
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-libmariadb)
vcpkg_fixup_pkgconfig()

set(link_lib " -lmariadb")
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(link_lib " -llibmariadb")
endif()
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    string(APPEND link_lib "client")
endif()
if(NOT link_lib STREQUAL " -lmariadb")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libmariadb.pc" " -lmariadb" "${link_lib}")
    if(NOT VCPKG_BUILD_TYPE)
        vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libmariadb.pc" " -lmariadb" "${link_lib}")
    endif()
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.LIB")
