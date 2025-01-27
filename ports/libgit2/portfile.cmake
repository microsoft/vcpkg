vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libgit2/libgit2
    REF "v${VERSION}"
    SHA512 38547ace676b933a3146c2a00405fc6815063a7af923b9f2c09c536ec717be77d19c513b383939054913ce617d7917c100a5cbd3378d101fcdb5eacd1d14f687
    HEAD_REF main
    PATCHES
        c-standard.diff # for 'inline' in system headers
        cli-include-dirs.diff
        dependencies.diff
        mingw-winhttp.diff
)
file(REMOVE_RECURSE
    "${SOURCE_PATH}/cmake/FindPCRE.cmake"
    "${SOURCE_PATH}/cmake/FindPCRE2.cmake"
    "${SOURCE_PATH}/deps/chromium-zlib"
    "${SOURCE_PATH}/deps/http-parser"
    "${SOURCE_PATH}/deps/pcre"
    "${SOURCE_PATH}/deps/winhttp"
    "${SOURCE_PATH}/deps/zlib"
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_CRT)

set(REGEX_BACKEND OFF)
set(USE_HTTPS OFF)
set(USE_SSH OFF)

function(set_regex_backend VALUE)
    if(REGEX_BACKEND)
        message(FATAL_ERROR "Only one regex backend (pcre,pcre2) is allowed")
    endif()
    set(REGEX_BACKEND ${VALUE} PARENT_SCOPE)
endfunction()

function(set_tls_backend VALUE)
    if(USE_HTTPS)
        message(FATAL_ERROR "Only one TLS backend (openssl,winhttp,sectransp,mbedtls) is allowed")
    endif()
    set(USE_HTTPS ${VALUE} PARENT_SCOPE)
endfunction()

foreach(GIT2_FEATURE ${FEATURES})
    if(GIT2_FEATURE STREQUAL "pcre")
        set_regex_backend("pcre")
    elseif(GIT2_FEATURE STREQUAL "pcre2")
        set_regex_backend("pcre2")
    elseif(GIT2_FEATURE STREQUAL "openssl")
        set_tls_backend("OpenSSL")
    elseif(GIT2_FEATURE STREQUAL "winhttp")
        set_tls_backend("WinHTTP")
    elseif(GIT2_FEATURE STREQUAL "sectransp")
        set_tls_backend("SecureTransport")
    elseif(GIT2_FEATURE STREQUAL "mbedtls")
        set_tls_backend("mbedTLS")
    elseif(GIT2_FEATURE STREQUAL "ssh")
        set(USE_SSH ON)
        message(STATUS "This version of `libgit2` uses the default (`libssh2`) backend. To use the newer backend which utilizes the `ssh` CLI from a local install of OpenSSH instead, create an overlay port of this with USE_SSH set to 'exec' and the `libssh2` dependency removed.")
        message(STATUS "This recipe is at ${CMAKE_CURRENT_LIST_DIR}")
        message(STATUS "See the overlay ports documentation at https://learn.microsoft.com/vcpkg/concepts/overlay-ports")
    endif()
endforeach()

if(NOT REGEX_BACKEND)
    message(FATAL_ERROR "Must choose pcre or pcre2 regex backend")
endif()

vcpkg_find_acquire_program(PKGCONFIG)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS GIT2_FEATURES
    FEATURES
        tools   BUILD_CLI
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTS=OFF
        -DUSE_HTTP_PARSER=system
        -DUSE_HTTPS=${USE_HTTPS}
        -DREGEX_BACKEND=${REGEX_BACKEND}
        -DUSE_SSH=${USE_SSH}
        -DSTATIC_CRT=${STATIC_CRT}
        "-DPKG_CONFIG_EXECUTABLE=${PKGCONFIG}"
        -DCMAKE_DISABLE_FIND_PACKAGE_GSSAPI:BOOL=ON
        ${GIT2_FEATURES}
    OPTIONS_DEBUG
        -DBUILD_CLI=OFF
    MAYBE_UNUSED_VARIABLES
        STATIC_CRT
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

if("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES git2 AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

set(file_list "${SOURCE_PATH}/COPYING")
if(NOT VCPKG_TARGET_IS_WINDOWS)
    file(WRITE "${CURRENT_BUILDTREES_DIR}/Notice for ntlmclient" [[
Copyright (c) Edward Thomson.  All rights reserved.
These source files are part of ntlmclient, distributed under the MIT license.
]])
    list(APPEND file_list "${CURRENT_BUILDTREES_DIR}/Notice for ntlmclient")
endif()
vcpkg_install_copyright(FILE_LIST ${file_list})
