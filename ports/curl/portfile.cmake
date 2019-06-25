include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO curl/curl
    REF curl-7_65_0
    SHA512 436b6b42654c1db2b3f69df410a7f28401a50faf18e74f328a93585c147541e697664b0e9e7df03239fd76c797c1bb4f435f4c668a6b0ad28bdd67e17f786491
    HEAD_REF master
    PATCHES
        0001_cmake.patch
        0002_fix_uwp.patch
        0003_fix_libraries.patch
        0004_nghttp2_staticlib.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" CURL_STATICLIB)

# Support HTTP2 TLS Download https://curl.haxx.se/ca/cacert.pem rename to curl-ca-bundle.crt, copy it to libcurl.dll location.
set(HTTP2_OPTIONS)
if("http2" IN_LIST FEATURES)
    set(HTTP2_OPTIONS -DUSE_NGHTTP2=ON)
endif()

# SSL
set(USE_OPENSSL OFF)
if("openssl" IN_LIST FEATURES)
    set(USE_OPENSSL ON)
endif()

set(USE_WINSSL OFF)
if("winssl" IN_LIST FEATURES)
    if(VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
        message(FATAL_ERROR "winssl is not supported on non-Windows platforms")
    endif()
    set(USE_WINSSL ON)
endif()

set(USE_MBEDTLS OFF)
if("mbedtls" IN_LIST FEATURES)
    set(USE_MBEDTLS ON)
endif()

set(USE_SECTRANSP OFF)
set(SECTRANSP_OPTIONS)
if("sectransp" IN_LIST FEATURES)
    if(NOT VCPKG_CMAKE_SYSTEM_NAME OR (VCPKG_CMAKE_SYSTEM_NAME AND NOT VCPKG_CMAKE_SYSTEM_NAME STREQUAL "Darwin"))
        message(FATAL_ERROR "sectransp is not supported on non-Apple platforms")
    endif()
    set(USE_SECTRANSP ON)
    set(SECTRANSP_OPTIONS
        -DCURL_CA_PATH=none
    )
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

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${UWP_OPTIONS}
        ${SECTRANSP_OPTIONS}
        ${HTTP2_OPTIONS}
        -DBUILD_TESTING=OFF
        -DBUILD_CURL_EXE=${BUILD_CURL_EXE}
        -DENABLE_MANUAL=OFF
        -DCURL_STATICLIB=${CURL_STATICLIB}
        -DCMAKE_USE_OPENSSL=${USE_OPENSSL}
        -DCMAKE_USE_WINSSL=${USE_WINSSL}
        -DCMAKE_USE_MBEDTLS=${USE_MBEDTLS}
        -DCMAKE_USE_SECTRANSP=${USE_SECTRANSP}
        -DCMAKE_USE_LIBSSH2=${USE_LIBSSH2}
        -DHTTP_ONLY=${USE_HTTP_ONLY}
        -DCMAKE_DISABLE_FIND_PACKAGE_Perl=ON
    OPTIONS_RELEASE
        -DBUILD_CURL_EXE=${BUILD_CURL_EXE}
    OPTIONS_DEBUG
        -DBUILD_CURL_EXE=OFF
        -DENABLE_DEBUG=ON
)

vcpkg_install_cmake()

if(EXISTS ${CURRENT_PACKAGES_DIR}/lib/cmake/CURL)
    vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/CURL)
elseif(EXISTS ${CURRENT_PACKAGES_DIR}/share/curl)
    vcpkg_fixup_cmake_targets()
else()
    message(FATAL_ERROR "Could not locate the curl config files")
endif()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/curl RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

# the native CMAKE_EXECUTABLE_SUFFIX does not work in portfiles, so emulate it
if(NOT VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore") # Windows
    set(EXECUTABLE_SUFFIX ".exe")
else()
    set(EXECUTABLE_SUFFIX "")
endif()

if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/curl${EXECUTABLE_SUFFIX}")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/curl")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/curl${EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/curl/curl${EXECUTABLE_SUFFIX}")
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/curl)

    if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
        file(READ "${CURRENT_PACKAGES_DIR}/share/curl/CURLTargets-release.cmake" RELEASE_MODULE)
        string(REPLACE "\${_IMPORT_PREFIX}/bin/curl${EXECUTABLE_SUFFIX}" "\${_IMPORT_PREFIX}/tools/curl/curl${EXECUTABLE_SUFFIX}" RELEASE_MODULE "${RELEASE_MODULE}")
        file(WRITE "${CURRENT_PACKAGES_DIR}/share/curl/CURLTargets-release.cmake" "${RELEASE_MODULE}")
    endif()
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib/pkgconfig ${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
else()
    file(REMOVE ${CURRENT_PACKAGES_DIR}/bin/curl-config ${CURRENT_PACKAGES_DIR}/debug/bin/curl-config)
endif()

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
