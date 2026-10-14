vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO machinezone/IXWebSocket
    REF "v${VERSION}"
    SHA512 1e01f2ba5b2853a2f3856ae05c2b92e16e266e13d95d5e4e96a0cb167f175087e222e7dc856df8ecfe497425aca5fff8564594ab7db59c1fbd93ca79449e4ecb
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        mbedtls           USE_MBED_TLS
        network-framework USE_NETWORK_FRAMEWORK
        openssl           USE_OPEN_SSL
        sectransp         USE_SECURE_TRANSPORT
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
# Static pkg-config consumers need the native backend's definitions and frameworks.
if("network-framework" IN_LIST FEATURES)
    foreach(lib_dir IN ITEMS lib debug/lib)
        set(pc_file "${CURRENT_PACKAGES_DIR}/${lib_dir}/pkgconfig/ixwebsocket.pc")
        if(EXISTS "${pc_file}")
            vcpkg_replace_string("${pc_file}" "Cflags:" "Cflags: -DIXWEBSOCKET_USE_TLS -DIXWEBSOCKET_USE_NETWORK_FRAMEWORK -DIXWEBSOCKET_USE_ZLIB")
            file(APPEND "${pc_file}" "\nLibs.private: -framework Network -framework Security -framework CoreFoundation\nRequires.private: zlib\n")
        endif()
    endforeach()
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
