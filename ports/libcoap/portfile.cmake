vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO obgm/libcoap
    REF 6c8b76d534a02cb22a6214025b6716946a7b6779
    SHA512 5c918335bf5c0f282cf7066360c5087b520f2c87d4350cc3a13323c02be1c2ac7420bdbef20f3cf5d7ddc9e8e36de0f7c853b8d3e93fff844b96c49a13c92dd9
    HEAD_REF master
    PATCHES fix-win-stat.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        epoll    WITH_EPOLL
        tcp      ENABLE_TCP
        examples ENABLE_EXAMPLES
        dtls     ENABLE_DTLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    DISABLE_PARALLEL_CONFIGURE
    OPTIONS
        ${FEATURE_OPTIONS}
        -DENABLE_TESTS=OFF
        -DENABLE_DOCS=OFF
        -DDTLS_BACKEND=openssl
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libcoap)
vcpkg_copy_pdbs()

if("examples" IN_LIST FEATURES)
    vcpkg_copy_tools(
        TOOL_NAMES coap-client coap-server coap-rd
        AUTO_CLEAN
    )
endif()


file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
