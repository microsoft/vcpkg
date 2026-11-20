vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO machinezone/IXWebSocket
    REF "v${VERSION}"
    SHA512 e4b25527397da6cab6f92568bc09263e25dda0f18e219443503eed9cf5b03ca52256f09bc1ca98c7c305b8933a8ab55f93d4a170e94d8911a5c280f3fe8a5c72
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        zlib      USE_ZLIB
        openssl   USE_OPEN_SSL
        mbedtls   USE_MBED_TLS
        sectransp USE_SECURE_TRANSPORT
)

# Compression does not select a TLS backend.
list(REMOVE_ITEM FEATURES "zlib")
string(COMPARE NOTEQUAL "${FEATURES}" "core" USE_TLS)

list(REMOVE_ITEM FEATURES "ssl")
list(LENGTH FEATURES num_features)
if(num_features GREATER "2")
    message(FATAL_ERROR "Can not select multiple ssl backends at the same time. Disable default features to disable the default ssl backend.")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DUSE_TLS=${USE_TLS}
    MAYBE_UNUSED_VARIABLES
        USE_SECURE_TRANSPORT
        USE_MBED_TLS
        USE_OPEN_SSL
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/ixwebsocket)
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
