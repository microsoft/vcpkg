set(VCPKG_BUILD_TYPE release) #header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO redboltz/async_mqtt
    REF "${VERSION}"
    SHA512 1e4c1ecb10de7f7554fbbf9c05be4d6d8399d40e52f54203f8ce246606b146ff26e5a5fd9dedb4b2c9067ff44f891e55897a27da7b6bd34db308c30aaf6c1f7b
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tls ASYNC_MQTT_USE_TLS
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DASYNC_MQTT_BUILD_TOOLS=OFF
        -DASYNC_MQTT_BUILD_EXAMPLES=OFF
        -DASYNC_MQTT_BUILD_UNIT_TESTS=OFF
        -DASYNC_MQTT_BUILD_SYSTEM_TESTS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME async_mqtt_iface CONFIG_PATH "lib/cmake/async_mqtt_iface")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
