include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO curl/curl
    REF curl-7_61_0
    SHA512 b6d2f57059e72139540cb93b945703857cb447920ed9b283993611453fed623432290adc5a3558181e3decc15c7cf54fff475010d922957807a37d1a1449be6c
    HEAD_REF master
    PATCHES
        ${CMAKE_CURRENT_LIST_DIR}/0001_cmake.patch
        ${CMAKE_CURRENT_LIST_DIR}/0002_fix_uwp.patch
        ${CMAKE_CURRENT_LIST_DIR}/0003_fix_libraries.patch
        ${CMAKE_CURRENT_LIST_DIR}/0004_nghttp2_staticlib.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" CURL_STATICLIB)

# Support HTTP2 TSL Download https://curl.haxx.se/ca/cacert.pem rename to curl-ca-bundle.crt, copy it to libcurl.dll location.
set(HTTP2_OPTIONS)
if("http2" IN_LIST FEATURES)
    set(HTTP2_OPTIONS -DUSE_NGHTTP2=ON)
endif()

# SSL
set(USE_OPENSSL OFF)
set(USE_WINSSL OFF)
if("ssl" IN_LIST FEATURES)
    if(CURL_USE_WINSSL)
        set(USE_WINSSL ON)
    else()
        set(USE_OPENSSL ON)
    endif()
endif()

# SSH
set(USE_LIBSSH2 OFF)
if("ssh" IN_LIST FEATURES)
    set(USE_LIBSSH2 ON)
endif()

# HTTP/HTTPS only
# Note that `HTTP_ONLY` curl option disables everything including HTTPS, which is not an option.
set(USE_HTTP_ONLY ON)
if("non-http" IN_LIST FEATURES)
    set(USE_HTTP_ONLY OFF)
endif()

# curl exe
set(BUILD_CURL_EXE OFF)
if("tool" IN_LIST FEATURES)
    set(BUILD_CURL_EXE ON)
endif()

# UWP targets
set(UWP_OPTIONS)
if(VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
    set(UWP_OPTIONS
        -DUSE_WIN32_LDAP=OFF
        -DCURL_DISABLE_TELNET=ON
        -DENABLE_IPV6=OFF
        -DENABLE_UNIX_SOCKETS=OFF
    )
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
        -DBUILD_CURL_EXE=${BUILD_CURL_EXE}
        -DENABLE_MANUAL=OFF
        -DCURL_STATICLIB=${CURL_STATICLIB}
        -DCMAKE_USE_OPENSSL=${USE_OPENSSL}
        -DCMAKE_USE_WINSSL=${USE_WINSSL}
        -DCMAKE_USE_LIBSSH2=${USE_LIBSSH2}
        -DHTTP_ONLY=${USE_HTTP_ONLY}
    OPTIONS_RELEASE
        -DBUILD_CURL_EXE=${BUILD_CURL_EXE}
    OPTIONS_DEBUG
        -DBUILD_CURL_EXE=OFF
        -DENABLE_DEBUG=ON
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/curl)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/curl)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/share/curl)
    vcpkg_fixup_cmake_targets(CONFIG_PATH share/curl)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/curl RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/curl.exe")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/curl")
    file(RENAME ${CURRENT_PACKAGES_DIR}/bin/curl.exe ${CURRENT_PACKAGES_DIR}/tools/curl/curl.exe)
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/curl)
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
    # Drop debug suffix, as FindCURL.cmake does not look for it
    if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/lib/libcurl-d.lib")
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libcurl-d.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libcurl.lib)
    endif()
else()
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/curl-config ${CURRENT_PACKAGES_DIR}/debug/bin/curl-config)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/lib/libcurl_imp.lib")
        file(RENAME ${CURRENT_PACKAGES_DIR}/lib/libcurl_imp.lib ${CURRENT_PACKAGES_DIR}/lib/libcurl.lib)
        file(RENAME ${CURRENT_PACKAGES_DIR}/debug/lib/libcurl-d_imp.lib ${CURRENT_PACKAGES_DIR}/debug/lib/libcurl.lib)
    endif()
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

vcpkg_test_cmake(PACKAGE_NAME CURL MODULE)
