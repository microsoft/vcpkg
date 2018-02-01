include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO curl/curl
    REF curl-7_58_0
    SHA512 148c25152732dd5ad2626bc70c7725577e25033a73eecefa4dd820927ec552f9c2d0235cc3f597404d3893eced7d5d2bd9522f6302b7f930e9f65912ac2c91f6
    HEAD_REF master
)

vcpkg_apply_patches(
    SOURCE_PATH ${SOURCE_PATH}
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0001_cmake.patch
        ${CMAKE_CURRENT_LIST_DIR}/0002_fix_uwp.patch
)

# Support HTTP2 TSL Download https://curl.haxx.se/ca/cacert.pem rename to curl-ca-bundle.crt, copy it to libcurl.dll location.
SET(HTTP2_OPTIONS)
if (VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
    SET(CURL_STATICLIB OFF)
    SET(HTTP2_OPTIONS
        -DUSE_NGHTTP2=ON
    )
else()
    SET(CURL_STATICLIB ON)
endif()

set(USE_OPENSSL ON)
if(CURL_USE_WINSSL)
    set(USE_OPENSSL OFF)
    set(USE_WINSSL ON)
    set(HTTP2_OPTIONS) ## disable HTTP2 when CURL_USE_WINSSL
endif()

set(UWP_OPTIONS)
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(UWP_OPTIONS
        -DUSE_WIN32_LDAP=OFF
        -DCURL_DISABLE_TELNET=ON
        -DENABLE_IPV6=OFF
        -DENABLE_UNIX_SOCKETS=OFF
    )
    set(HTTP2_OPTIONS) ## disable curl HTTP2 support
endif()

vcpkg_find_acquire_program(PERL)
get_filename_component(PERL_PATH ${PERL} DIRECTORY)
set(ENV{PATH} "$ENV{PATH};${PERL_PATH}")

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${UWP_OPTIONS}
        ${HTTP2_OPTIONS}
        -DBUILD_TESTING=OFF
        -DBUILD_CURL_EXE=OFF
        -DENABLE_MANUAL=OFF
        -DCURL_STATICLIB=${CURL_STATICLIB}
        -DCMAKE_USE_OPENSSL=${USE_OPENSSL}
        -DCMAKE_USE_WINSSL=${USE_WINSSL}
    OPTIONS_DEBUG
        -DENABLE_DEBUG=ON
)

vcpkg_install_cmake()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/curl RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    # Drop debug suffix, as FindCURL.cmake does not look for it
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libcurl-d.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libcurl.lib)
else()
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/curl-config ${CURRENT_PACKAGES_DIR}/debug/bin/curl-config)
    file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libcurl_imp.lib ${CURRENT_PACKAGES_DIR}/lib/libcurl.lib)
    file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libcurl-d_imp.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libcurl.lib)
endif()
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(READ ${CURRENT_PACKAGES_DIR}/include/curl/curl.h CURL_H)
if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    string(REPLACE "#ifdef CURL_STATICLIB" "#if 1" CURL_H "${CURL_H}")
else()
    string(REPLACE "#ifdef CURL_STATICLIB" "#if 0" CURL_H "${CURL_H}")
endif()
file(WRITE ${CURRENT_PACKAGES_DIR}/include/curl/curl.h "${CURL_H}")

vcpkg_copy_pdbs()

file(COPY ${CMAKE_CURRENT_LIST_DIR}/usage DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
