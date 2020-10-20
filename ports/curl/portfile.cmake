vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO curl/curl
    REF 315ee3fe75dade912b48a21ceec9ccda0230d937 #curl-7_73_0
    SHA512 db9385d63688256c335f08fe044c67e7c17e2fbcbb47df234d5f9a1586b259edb07a37845c2ad85d2da00738b19dc0e718d91d05b2881c2828fec2660f858444
    HEAD_REF master
    PATCHES
        0002_fix_uwp.patch
        0004_nghttp2_staticlib.patch
        0005_remove_imp_suffix.patch
        0006_fix_tool_depends.patch
        0007_disable_tool_export_curl_target.patch
        0009_fix_openssl_config.patch
        0010_fix_othertests_cmake.patch
        0011_fix_static_build.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" CURL_STATICLIB)

# schannel will enable sspi, but sspi do not support uwp
if(("schannel" IN_LIST FEATURES OR "sspi" IN_LIST FEATURES OR "tool" IN_LIST FEATURES) AND (NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_UWP))
    message(FATAL_ERROR "schannel,sspi,tool are not supported on non-Windows and uwp platforms")
endif()

if("sectransp" IN_LIST FEATURES AND NOT VCPKG_TARGET_IS_OSX)
    message(FATAL_ERROR "sectransp is not supported on non-Apple platforms")
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    # Support HTTP2 TLS Download https://curl.haxx.se/ca/cacert.pem rename to curl-ca-bundle.crt, copy it to libcurl.dll location.
    http2       USE_NGHTTP2
    openssl     CMAKE_USE_OPENSSL
    mbedtls     CMAKE_USE_MBEDTLS
    ssh         CMAKE_USE_LIBSSH2
    tool        BUILD_CURL_EXE
    c-ares      ENABLE_ARES
    sspi        CURL_WINDOWS_SSPI
    brotli      CURL_BROTLI
    schannel    CMAKE_USE_SCHANNEL
    sectransp   CMAKE_USE_SECTRANSP
    
    INVERTED_FEATURES
    non-http HTTP_ONLY
)

set(SECTRANSP_OPTIONS)
if("sectransp" IN_LIST FEATURES)
    set(SECTRANSP_OPTIONS -DCURL_CA_PATH=none)
endif()

# UWP targets
set(UWP_OPTIONS)
if(VCPKG_TARGET_IS_UWP)
    set(UWP_OPTIONS
        -DUSE_WIN32_LDAP=OFF
        -DCURL_DISABLE_TELNET=ON
        -DENABLE_IPV6=OFF
        -DENABLE_UNIX_SOCKETS=OFF
    )
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS}
        ${UWP_OPTIONS}
        ${SECTRANSP_OPTIONS}
        -DBUILD_TESTING=OFF
        -DENABLE_MANUAL=OFF
        -DCURL_STATICLIB=${CURL_STATICLIB}
        -DCMAKE_DISABLE_FIND_PACKAGE_Perl=ON
        -DENABLE_DEBUG=ON
        -DCURL_CA_FALLBACK=ON
)

vcpkg_install_cmake()

vcpkg_copy_pdbs()

if ("tool" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES curl AUTO_CLEAN)
endif()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/CURL)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    file(INSTALL ${CURRENT_PACKAGES_DIR}/bin/curl-config DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/curl-config ${CURRENT_PACKAGES_DIR}/debug/bin/curl-config)
    #Fix install path
    file(READ ${CURRENT_PACKAGES_DIR}/share/${PORT}/curl-config CURL_CONFIG)
    string(REPLACE "${CURRENT_PACKAGES_DIR}" "${CURRENT_INSTALLED_DIR}" CURL_CONFIG "${CURL_CONFIG}")
    file(WRITE ${CURRENT_PACKAGES_DIR}/share/${PORT}/curl-config "${CURL_CONFIG}")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/curl/curl.h
        "#ifdef CURL_STATICLIB"
        "#if 1"
    )
else()
    vcpkg_replace_string(${CURRENT_PACKAGES_DIR}/include/curl/curl.h
        "#ifdef CURL_STATICLIB"
        "#if 0"
    )
endif()

file(INSTALL ${CURRENT_PORT_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)