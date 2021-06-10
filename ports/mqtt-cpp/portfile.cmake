vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO redboltz/mqtt_cpp
    REF v10.0.0
    SHA512 fc082f2d7416723db9b01bef8878b422f6717148bec28e2b4a3b8993cfa5ff4531f187ff7de556c5087d43010cf7e76e9fd3c8423e22dc7bf7f05d0f644e2923
    HEAD_REF master
)

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        log MQTT_USE_LOG
        tls MQTT_USE_TLS
        ws MQTT_USE_WS
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
	${OUT_FEATURE_OPTIONS}
	-DMQTT_USE_STR_CHECK=ON
        -DMQTT_BUILD_EXAMPLES=OFF
        -DMQTT_BUILD_TESTS=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/mqtt_cpp_iface)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/lib)
file(INSTALL ${SOURCE_PATH}/LICENSE_1_0.txt DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
