vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO curl/curl
    REF e052859759b34d0e05ce0f17244873e5cd7b457b #curl-7_74_0
    SHA512 3dbbab00dda4f0e7d012fab358d2dd1362ff0c0f59c81f638fb547acba6f74a61c306906892447af3b18e8b0ebb93ebb8e0ac77e92247864bfa3a9c4ce7ea1d0
    HEAD_REF master
    PATCHES
        0002_fix_uwp.patch
        0004_nghttp2_staticlib.patch
        0005_remove_imp_suffix.patch
        0006_fix_tool_depends.patch
        0007_disable_tool_export_curl_target.patch
        0010_fix_othertests_cmake.patch
        0011_fix_static_build.patch
        0012-fix-dependency-idn2.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" CURL_STATICLIB)

# schannel will enable sspi, but sspi do not support uwp
foreach(feature "schannel" "sspi" "tool")
    if(feature IN_LIST FEATURES AND VCPKG_TARGET_IS_UWP)
        message(FATAL_ERROR "Feature ${feature} is not supported on UWP.")
    endif()
endforeach()

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
    idn2        CMAKE_USE_IDN2

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
        ${ADDITIONAL_SCRIPTS}
        ${EXTRA_ARGS}
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

#Fix install path
file(READ ${CURRENT_PACKAGES_DIR}/bin/curl-config CURL_CONFIG)
string(REPLACE "${CURRENT_PACKAGES_DIR}" "\${prefix}" CURL_CONFIG "${CURL_CONFIG}")
string(REPLACE "${CURRENT_INSTALLED_DIR}" "\${prefix}" CURL_CONFIG "${CURL_CONFIG}")
string(REPLACE "\nprefix=\${prefix}" [=[prefix=$(CDPATH= cd -- "$(dirname -- "$0")"/../.. && pwd -P)]=] CURL_CONFIG "${CURL_CONFIG}")
file(WRITE ${CURRENT_PACKAGES_DIR}/bin/curl-config "${CURL_CONFIG}")
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/curl-config ${CURRENT_PACKAGES_DIR}/share/${PORT}/curl-config)
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/curl-config)

file(GLOB FILES ${CURRENT_PACKAGES_DIR}/bin/*)
if(NOT FILES)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin)
endif()
file(GLOB FILES ${CURRENT_PACKAGES_DIR}/debug/bin/*)
if(NOT FILES)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/bin)
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


# Fix the pkgconfig file for debug
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    file(READ ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-dbg/libcurl.pc _contents)
    string(REPLACE " -lcurl" " -lcurl-d" _contents "${_contents}")
    string(REPLACE " -loptimized " " " _contents "${_contents}")
    string(REPLACE " -ldebug " " " _contents "${_contents}")
    string(REPLACE " ${CURRENT_INSTALLED_DIR}/lib/pthreadVC3.lib" "" _contents "${_contents}")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
    file(WRITE ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libcurl.pc "${_contents}")
endif()

# Fix the pkgconfig file for release
if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    file(READ ${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}-rel/libcurl.pc _contents)
    string(REPLACE " -loptimized " " " _contents "${_contents}")
    string(REPLACE " -ldebug " " " _contents "${_contents}")
    string(REPLACE " ${CURRENT_INSTALLED_DIR}/debug/lib/pthreadVC3d.lib" "" _contents "${_contents}")
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/lib/pkgconfig)
    file(WRITE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libcurl.pc "${_contents}")
endif()

vcpkg_fixup_pkgconfig()

file(INSTALL "${CURRENT_PORT_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
