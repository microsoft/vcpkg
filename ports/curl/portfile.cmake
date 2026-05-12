string(REPLACE "." "_" curl_version "curl-${VERSION}")

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO curl/curl
    REF ${curl_version}
    SHA512 452a76a238b6fa63d579eea37551cab9a02003fd542895905cf5ddc6b01b845697d30ebf5bf7b74db2c73113da3dcaf88d09093c9e2bdf8b4958690625d8800c
    HEAD_REF master
    PATCHES
        dependencies.patch
)
# The on-the-fly tarballs do not carry the details of release tarballs.
vcpkg_replace_string("${SOURCE_PATH}/include/curl/curlver.h" [[-DEV"]] [["]])
vcpkg_replace_string("${SOURCE_PATH}/include/curl/curlver.h" [[LIBCURL_TIMESTAMP "[unreleased]"]] [[LIBCURL_TIMESTAMP "[vcpkg]"]])

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        brotli      CURL_BROTLI
        c-ares      ENABLE_ARES
        gnutls      CURL_USE_GNUTLS
        gsasl       CURL_USE_GSASL
        gssapi      CURL_USE_GSSAPI
        gssapi      VCPKG_LOCK_FIND_PACKAGE_GSS
        http2       USE_NGHTTP2
        http2       VCPKG_LOCK_FIND_PACKAGE_NGHTTP2
        http3       USE_NGTCP2
        httpsrr     USE_HTTPSRR
        idn2        USE_LIBIDN2
        idn2        VCPKG_LOCK_FIND_PACKAGE_Libidn2
        ldap        VCPKG_LOCK_FIND_PACKAGE_LDAP
        mbedtls     CURL_USE_MBEDTLS
        openssl     CURL_CA_FALLBACK
        openssl     CURL_USE_OPENSSL
        psl         CURL_USE_LIBPSL
        ssh         CURL_USE_LIBSSH2
        ssh         VCPKG_LOCK_FIND_PACKAGE_Libssh2
        ssls-export USE_SSLS_EXPORT
        sspi        CURL_WINDOWS_SSPI
        tool        BUILD_CURL_EXE
        winidn      USE_WIN32_IDN
        wolfssl     CURL_USE_WOLFSSL
        zstd        CURL_ZSTD
    INVERTED_FEATURES
        ldap        CURL_DISABLE_LDAP
        ldap        CURL_DISABLE_LDAPS
        non-http    HTTP_ONLY
        websockets  CURL_DISABLE_WEBSOCKETS
)

if("ssl" IN_LIST FEATURES AND
    NOT "http3" IN_LIST FEATURES AND
    # Match curl[ssl]'s "platform": "windows & !uwp"
    (VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_UWP))
    list(APPEND FEATURE_OPTIONS -DCURL_USE_SCHANNEL=ON)
endif()

if("http3" IN_LIST FEATURES AND
    ("wolfssl" IN_LIST FEATURES OR
     "mbedtls" IN_LIST FEATURES OR
     "gnutls" IN_LIST FEATURES))
    message(FATAL_ERROR "http3 is incompatible with curl multi-ssl, preventing combination with wolfssl, mbedtls or \
gnutls in vcpkg's curated registry. To use curl http3 on ngtcp2 on one of the other TLS backends, author an \
overlay-port which exchanges curl[ssl]'s and curl[http3]'s openssl dependencies with the backend you want.")
endif()

set(OPTIONS "")

if(VCPKG_TARGET_IS_UWP)
    list(APPEND OPTIONS
        -DCURL_DISABLE_TELNET=ON
        -DENABLE_UNIX_SOCKETS=OFF
    )
endif()

if(VCPKG_TARGET_IS_WINDOWS)
    list(APPEND OPTIONS -DENABLE_UNICODE=ON)
endif()

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "-DCMAKE_PROJECT_INCLUDE=${CMAKE_CURRENT_LIST_DIR}/cmake-project-include.cmake"
        ${FEATURE_OPTIONS}
        ${OPTIONS}
        -DBUILD_TESTING=OFF
        -DENABLE_CURL_MANUAL=OFF
        -DIMPORT_LIB_SUFFIX=   # empty
        -DSHARE_LIB_OBJECT=OFF
        -DCURL_USE_CMAKECONFIG=ON
        -DCURL_USE_PKGCONFIG=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Perl=ON
    MAYBE_UNUSED_VARIABLES
        VCPKG_LOCK_FIND_PACKAGE_GSS
        VCPKG_LOCK_FIND_PACKAGE_LDAP
        VCPKG_LOCK_FIND_PACKAGE_Libidn2
        VCPKG_LOCK_FIND_PACKAGE_Libssh2
        VCPKG_LOCK_FIND_PACKAGE_NGHTTP2
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/CURL)

vcpkg_fixup_pkgconfig()
set(namespec "curl")
if(VCPKG_TARGET_IS_WINDOWS AND NOT VCPKG_TARGET_IS_MINGW)
    set(namespec "libcurl")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libcurl.pc" " -lcurl" " -l${namespec}")
endif()
if(NOT DEFINED VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libcurl.pc" " -lcurl" " -l${namespec}-d")
endif()

if ("tool" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES curl AUTO_CLEAN)
endif()

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/bin/curl-config" "${CURRENT_PACKAGES_DIR}" "\${prefix}")
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/bin/curl-config" "${CURRENT_INSTALLED_DIR}" "\${prefix}" IGNORE_UNCHANGED)
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/bin/curl-config" "\nprefix='\${prefix}'" [=[prefix=$(CDPATH= cd -- "$(dirname -- "$0")"/../../.. && pwd -P)]=])
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin")
file(RENAME "${CURRENT_PACKAGES_DIR}/bin/curl-config" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/bin/curl-config")
if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/curl-config")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/bin/curl-config" "${CURRENT_PACKAGES_DIR}" "\${prefix}")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/bin/curl-config" "${CURRENT_INSTALLED_DIR}" "\${prefix}" IGNORE_UNCHANGED)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/bin/curl-config" "\nprefix='\${prefix}/debug'" [=[prefix=$(CDPATH= cd -- "$(dirname -- "$0")"/../../../.. && pwd -P)]=])
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/bin/curl-config" "\nexec_prefix=\"\${prefix}\"" "\nexec_prefix=\"\${prefix}/debug\"")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/bin/curl-config" "-lcurl" "-l${namespec}-d")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/bin/curl-config" "curl." "curl-d.")
    file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin")
    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin/curl-config" "${CURRENT_PACKAGES_DIR}/tools/${PORT}/debug/bin/curl-config")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
if(VCPKG_LIBRARY_LINKAGE STREQUAL "static" OR NOT VCPKG_TARGET_IS_WINDOWS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/curl/curl.h"
        "#ifdef CURL_STATICLIB"
        "#if 1"
    )
endif()

file(INSTALL "${CURRENT_PORT_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

file(READ "${SOURCE_PATH}/lib/curlx/inet_ntop.c" inet_ntop_c)
string(REGEX REPLACE "#i.*" "" inet_ntop_c "${inet_ntop_c}")
set(inet_ntop_copyright "${CURRENT_BUILDTREES_DIR}/inet_ntop.c and inet_pton.c Notice")
file(WRITE "${inet_ntop_copyright}" "${inet_ntop_c}")

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/COPYING"
        "${inet_ntop_copyright}"
)
