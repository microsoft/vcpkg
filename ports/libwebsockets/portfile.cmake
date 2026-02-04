vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO warmcat/libwebsockets
    REF "v${VERSION}"
    SHA512 8427ade9325051b486321b9d0b07b136428ed28f34972a3cc0b0440a9f1efab7b34ee82b6b778eb39669dea08d47976eef04a99f8e15ba03cb6b3c1dc28cb9f9
    HEAD_REF master
    PATCHES
        fix-dependency-libuv.patch
        fix-build-error.patch
        export-include-path.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" LWS_WITH_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" LWS_WITH_SHARED)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" STATIC_CRT)

## All LWS options could be possible features:
# #
# # Major individual features
# #
# option(LWS_WITH_NETWORK "Compile with network-related code" ON)
# option(LWS_ROLE_H1 "Compile with support for http/1 (needed for ws)" ON)
# option(LWS_ROLE_WS "Compile with support for websockets" ON)
# option(LWS_ROLE_DBUS "Compile with support for DBUS" OFF)
# option(LWS_ROLE_RAW_PROXY "Raw packet proxy" OFF)
# option(LWS_WITH_HTTP2 "Compile with server support for HTTP/2" ON)
# option(LWS_WITH_LWSWS "Libwebsockets Webserver" OFF)
# option(LWS_WITH_CGI "Include CGI (spawn process with network-connected stdin/out/err) APIs" OFF)
# option(LWS_IPV6 "Compile with support for ipv6" OFF)
# option(LWS_UNIX_SOCK "Compile with support for UNIX domain socket" OFF)
# option(LWS_WITH_PLUGINS "Support plugins for protocols and extensions" OFF)
# option(LWS_WITH_HTTP_PROXY "Support for HTTP proxying" OFF)
# option(LWS_WITH_ZIP_FOPS "Support serving pre-zipped files" OFF)
# option(LWS_WITH_SOCKS5 "Allow use of SOCKS5 proxy on client connections" OFF)
# option(LWS_WITH_GENERIC_SESSIONS "With the Generic Sessions plugin" OFF)
# option(LWS_WITH_PEER_LIMITS "Track peers and restrict resources a single peer can allocate" OFF)
# option(LWS_WITH_ACCESS_LOG "Support generating Apache-compatible access logs" OFF)
# option(LWS_WITH_RANGES "Support http ranges (RFC7233)" OFF)
# option(LWS_WITH_SERVER_STATUS "Support json + jscript server monitoring" OFF)
# option(LWS_WITH_THREADPOOL "Managed worker thread pool support (relies on pthreads)" OFF)
# option(LWS_WITH_HTTP_STREAM_COMPRESSION "Support HTTP stream compression" OFF)
# option(LWS_WITH_HTTP_BROTLI "Also offer brotli http stream compression (requires LWS_WITH_HTTP_STREAM_COMPRESSION)" OFF)
# option(LWS_WITH_ACME "Enable support for ACME automatic cert acquisition + maintenance (letsencrypt etc)" OFF)
# option(LWS_WITH_HUBBUB "Enable libhubbub rewriting support" OFF)
# option(LWS_WITH_FTS "Full Text Search support" OFF)
# #
# # TLS library options... all except mbedTLS are basically OpenSSL variants.
# #
# option(LWS_WITH_SSL "Include SSL support (defaults to OpenSSL or similar, mbedTLS if LWS_WITH_MBEDTLS is set)" ON)
# option(LWS_WITH_MBEDTLS "Use mbedTLS (>=2.0) replacement for OpenSSL. When setting this, you also may need to specify LWS_MBEDTLS_LIBRARIES and LWS_MBEDTLS_INCLUDE_DIRS" OFF)
# option(LWS_WITH_BORINGSSL "Use BoringSSL replacement for OpenSSL" OFF)
# option(LWS_WITH_CYASSL "Use CyaSSL replacement for OpenSSL. When setting this, you also need to specify LWS_CYASSL_LIBRARIES and LWS_CYASSL_INCLUDE_DIRS" OFF)
# option(LWS_WITH_WOLFSSL "Use wolfSSL replacement for OpenSSL. When setting this, you also need to specify LWS_WOLFSSL_LIBRARIES and LWS_WOLFSSL_INCLUDE_DIRS" OFF)
# option(LWS_SSL_CLIENT_USE_OS_CA_CERTS "SSL support should make use of the OS-installed CA root certs" ON)
# #
# # Event library options (may select multiple, or none for default poll()
# #
# option(LWS_WITH_LIBEV "Compile with support for libev" OFF)
# option(LWS_WITH_LIBUV "Compile with support for libuv" OFF)
# option(LWS_WITH_LIBEVENT "Compile with support for libevent" OFF)
# #
# # Static / Dynamic build options
# #
# option(LWS_WITH_STATIC "Build the static version of the library" ON)
# option(LWS_WITH_SHARED "Build the shared version of the library" ON)
# option(LWS_LINK_TESTAPPS_DYNAMIC "Link the test apps to the shared version of the library. Default is to link statically" OFF)
# option(LWS_STATIC_PIC "Build the static version of the library with position-independent code" OFF)
# #
# # Specific platforms
# #
# option(LWS_WITH_ESP32 "Build for ESP32" OFF)
# option(LWS_WITH_ESP32_HELPER "Build ESP32 helper" OFF)
# option(LWS_PLAT_OPTEE "Build for OPTEE" OFF)
# #
# # Client / Server / Test Apps build control
# #
# option(LWS_WITHOUT_CLIENT "Don't build the client part of the library" OFF)
# option(LWS_WITHOUT_SERVER "Don't build the server part of the library" OFF)
# option(LWS_WITHOUT_TESTAPPS "Don't build the libwebsocket-test-apps" OFF)
# option(LWS_WITHOUT_TEST_SERVER "Don't build the test server" OFF)
# option(LWS_WITHOUT_TEST_SERVER_EXTPOLL "Don't build the test server version that uses external poll" OFF)
# option(LWS_WITHOUT_TEST_PING "Don't build the ping test application" OFF)
# option(LWS_WITHOUT_TEST_CLIENT "Don't build the client test application" OFF)
# #
# # Extensions (permessage-deflate)
# #
# option(LWS_WITHOUT_EXTENSIONS "Don't compile with extensions" ON)
# #
# # Helpers + misc
# #
# option(LWS_WITHOUT_BUILTIN_GETIFADDRS "Don't use the BSD getifaddrs implementation from libwebsockets if it is missing (this will result in a compilation error) ... The default is to assume that your libc provides it. On some systems such as uclibc it doesn't exist." OFF)
# option(LWS_FALLBACK_GETHOSTBYNAME "Also try to do dns resolution using gethostbyname if getaddrinfo fails" OFF)
# option(LWS_WITHOUT_BUILTIN_SHA1 "Don't build the lws sha-1 (eg, because openssl will provide it" OFF)
# option(LWS_WITH_LATENCY "Build latency measuring code into the library" OFF)
# option(LWS_WITHOUT_DAEMONIZE "Don't build the daemonization api" ON)
# option(LWS_SSL_SERVER_WITH_ECDH_CERT "Include SSL server use ECDH certificate" OFF)
# option(LWS_WITH_LEJP "With the Lightweight JSON Parser" ON)
# option(LWS_WITH_SQLITE3 "Require SQLITE3 support" OFF)
# option(LWS_WITH_STRUCT_JSON "Generic struct serialization to and from JSON" ON)
# option(LWS_WITH_STRUCT_SQLITE3 "Generic struct serialization to and from SQLITE3" OFF)
# option(LWS_WITH_SMTP "Provide SMTP support" OFF)
# if (WIN32 OR LWS_WITH_ESP32)
# option(LWS_WITH_DIR "Directory scanning api support" OFF)
# option(LWS_WITH_LEJP_CONF "With LEJP configuration parser as used by lwsws" OFF)
# else()
# option(LWS_WITH_DIR "Directory scanning api support" ON)
# option(LWS_WITH_LEJP_CONF "With LEJP configuration parser as used by lwsws" ON)
# endif()
# option(LWS_WITH_NO_LOGS "Disable all logging from being compiled in" OFF)
# option(LWS_AVOID_SIGPIPE_IGN "Android 7+ reportedly needs this" OFF)
# option(LWS_WITH_STATS "Keep statistics of lws internal operations" OFF)
# option(LWS_WITH_JOSE "JSON Web Signature / Encryption / Keys (RFC7515/6/) API" OFF)
# option(LWS_WITH_GENCRYPTO "Enable support for Generic Crypto apis independent of TLS backend" OFF)
# option(LWS_WITH_SELFTESTS "Selftests run at context creation" OFF)
# option(LWS_WITH_GCOV "Build with gcc gcov coverage instrumentation" OFF)
# option(LWS_WITH_EXPORT_LWSTARGETS "Export libwebsockets CMake targets.  Disable if they conflict with an outer cmake project." ON)
# option(LWS_REPRODUCIBLE "Build libwebsockets reproducible. It removes the build user and hostname from the build" ON)
# option(LWS_WITH_MINIMAL_EXAMPLES "Also build the normally standalone minimal examples, for QA" OFF)
# option(LWS_WITH_LWSAC "lwsac Chunk Allocation api" ON)
# option(LWS_WITH_CUSTOM_HEADERS "Store and allow querying custom HTTP headers (H1 only)" ON)
# option(LWS_WITH_DISKCACHE "Hashed cache directory with lazy LRU deletion to size limit" OFF)
# option(LWS_WITH_ASAN "Build with gcc runtime sanitizer options enabled (needs libasan)" OFF)
# option(LWS_WITH_DIR "Directory scanning api support" OFF)
# option(LWS_WITH_LEJP_CONF "With LEJP configuration parser as used by lwsws" OFF)
# option(LWS_WITH_ZLIB "Include zlib support (required for extensions)" OFF)
# option(LWS_WITH_BUNDLED_ZLIB "Use bundled zlib version (Windows only)" ${LWS_WITH_BUNDLED_ZLIB_DEFAULT})
# option(LWS_WITH_MINIZ "Use miniz instead of zlib" OFF)
# option(LWS_WITH_DEPRECATED_LWS_DLL "Migrate to lws_dll2 instead ASAP" OFF)
# option(LWS_WITH_SEQUENCER "lws_seq_t support" ON)
# option(LWS_WITH_EXTERNAL_POLL "Support external POLL integration using callback messages (not recommended)" OFF)
# option(LWS_WITH_LWS_DSH "Support lws_dsh_t Disordered Shared Heap" OFF)
##

set(EXTRA_ARGS)
if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "wasm32")
    set(EXTRA_ARGS "-DLWS_WITH_LIBUV=ON")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${EXTRA_ARGS}
        -DLWS_WITH_STATIC=${LWS_WITH_STATIC}
        -DLWS_WITH_SHARED=${LWS_WITH_SHARED}
        -DLWS_MSVC_STATIC_RUNTIME=${STATIC_CRT}
        -DLWS_WITH_GENCRYPTO=ON
        -DLWS_WITH_TLS=ON
        -DLWS_WITH_BUNDLED_ZLIB=OFF
        -DLWS_WITHOUT_TESTAPPS=ON
        -DLWS_IPV6=ON
        -DLWS_WITH_HTTP2=ON
        -DLWS_WITH_HTTP_STREAM_COMPRESSION=ON # Since zlib is already a dependency
        -DLWS_WITH_EXTERNAL_POLL=ON
    # OPTIONS_RELEASE -DOPTIMIZE=1
    # OPTIONS_DEBUG -DDEBUGGABLE=1
)

vcpkg_cmake_install()

if (VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(CONFIG_PATH cmake)
else()
    vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libwebsockets)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/libwebsockets-test-server")
file(READ "${CURRENT_PACKAGES_DIR}/share/libwebsockets/libwebsockets-config.cmake" LIBWEBSOCKETSCONFIG_CMAKE)
string(REPLACE "/../include" "/../../include" LIBWEBSOCKETSCONFIG_CMAKE "${LIBWEBSOCKETSCONFIG_CMAKE}")
file(WRITE "${CURRENT_PACKAGES_DIR}/share/libwebsockets/libwebsockets-config.cmake" "${LIBWEBSOCKETSCONFIG_CMAKE}")

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    vcpkg_replace_string( "${CURRENT_PACKAGES_DIR}/share/libwebsockets/LibwebsocketsTargets-debug.cmake" "websockets_static.lib" "websockets.lib" IGNORE_UNCHANGED)
endif()

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
    vcpkg_replace_string( "${CURRENT_PACKAGES_DIR}/share/libwebsockets/LibwebsocketsTargets-release.cmake" "websockets_static.lib" "websockets.lib" IGNORE_UNCHANGED)
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL static)
    if (VCPKG_TARGET_IS_WINDOWS)
        file(RENAME "${CURRENT_PACKAGES_DIR}/debug/lib/websockets_static.lib" "${CURRENT_PACKAGES_DIR}/debug/lib/websockets.lib")
        file(RENAME "${CURRENT_PACKAGES_DIR}/lib/websockets_static.lib" "${CURRENT_PACKAGES_DIR}/lib/websockets.lib")
    endif()
endif ()

vcpkg_copy_pdbs()
vcpkg_fixup_pkgconfig()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/lws_config.h" "${CURRENT_PACKAGES_DIR}" "")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
