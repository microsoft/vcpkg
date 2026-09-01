set(VCPKG_BUILD_TYPE release) #header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO redboltz/async_mqtt
    REF "${VERSION}"
    SHA512 c4ff7288925b90cfa98304621f8f2688d29fe3695b209908f6578d1c9638efabd49185d2e8ed35e5bf4a80b38aeb8fb03229cae185d661e7f49a5800556ebb93
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
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME async_mqtt_iface CONFIG_PATH "lib/cmake/async_mqtt_iface")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
