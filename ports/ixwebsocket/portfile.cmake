vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO machinezone/IXWebSocket
    REF "v${VERSION}"
    SHA512 de43c240282e34b905444f84eb5825f55e6f4d68dc9c3937318233a3916d1bb6934fb5bbbe9485c6e181e14c968189559b6837447d8f66ccd73d24634f7749d1
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        openssl   USE_OPEN_SSL
        mbedtls   USE_MBED_TLS
        sectransp USE_SECURE_TRANSPORT
)

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
