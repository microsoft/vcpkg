vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO eclipse/paho.mqtt.cpp
  REF "v${VERSION}"
  SHA512 1d14627a3f9f3fb8d0c49a72dda849909eb2dd85c151e912225aec99c0806b05ef5edf871be2f202077ff2465f89eefb0a791de265523c1aeb24e86debc1ade3
  HEAD_REF master
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" PAHO_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" PAHO_BUILD_SHARED)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    "ssl" PAHO_WITH_SSL
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DPAHO_BUILD_STATIC=${PAHO_BUILD_STATIC}
    -DPAHO_BUILD_SHARED=${PAHO_BUILD_SHARED}
    ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME pahomqttcpp CONFIG_PATH "lib/cmake/PahoMqttCpp")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/about.html")
