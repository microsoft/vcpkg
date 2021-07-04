# libgit2 uses winapi functions not available in WindowsStore
vcpkg_fail_port_install(ON_TARGET "uwp")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libgit2/libgit2
    REF 7f4fa178629d559c037a1f72f79f79af9c1ef8ce#version 1.1.0
    SHA512 2fdbbb263fe71dc6d04b64c2967e7acff1a5b6102e62d69c9a7ea1b6777ab74a1625e798438ea239d8b489648a9335833f937f893f73a66e16c658eae453ab62
    HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_CRT)

set(REGEX_BACKEND OFF)
set(USE_HTTPS OFF)

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
        if(NOT VCPKG_TARGET_IS_WINDOWS)
            message(FATAL_ERROR "winhttp is not supported on non-Windows and uwp platforms")
        endif()
        set_tls_backend("WinHTTP")
    elseif(GIT2_FEATURE STREQUAL "sectransp")
        if(NOT VCPKG_TARGET_IS_OSX)
            message(FATAL_ERROR "sectransp is not supported on non-Apple platforms")
        endif()
        set_tls_backend("SecureTransport")
    elseif(GIT2_FEATURE STREQUAL "mbedtls")
        if(VCPKG_TARGET_IS_WINDOWS)
            message(FATAL_ERROR "mbedtls is not supported on Windows because a certificate file must be specified at compile time")
        endif()
        set_tls_backend("mbedTLS")
    endif()
endforeach()

if(NOT REGEX_BACKEND)
    message(FATAL_ERROR "Must choose pcre or pcre2 regex backend")
endif()

vcpkg_check_features(
    OUT_FEATURE_OPTIONS GIT2_FEATURES
    FEATURES
        ssh USE_SSH
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DBUILD_CLAR=OFF
        -DUSE_HTTP_PARSER=system
        -DUSE_HTTPS=${USE_HTTPS}
        -DREGEX_BACKEND=${REGEX_BACKEND}
        -DSTATIC_CRT=${STATIC_CRT}
        ${GIT2_FEATURES}
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
