vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO machinezone/IXWebSocket
    REF "v${VERSION}"
    SHA512 698ad96f25f53bf48906201826008bad46c657f8043d3653988716ddd9fb5dfeb52cebc002b3af76b91d0561155607a5f38bbc2c808aa67f438432207da82a35
    PATCHES
        fix-C2065-of-errorMsg.patch
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
