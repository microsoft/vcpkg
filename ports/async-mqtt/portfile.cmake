set(VCPKG_BUILD_TYPE release) #header-only

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO redboltz/async_mqtt
    REF "${VERSION}"
    SHA512 7670c64f6c1ed98434620e107474283fec802098421c77ba503fc732141597ae0926d187be0cbcc0a86433c502a21cdc19a6d25d8e009ee1c72fd691f9fe9163
    HEAD_REF main
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
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
