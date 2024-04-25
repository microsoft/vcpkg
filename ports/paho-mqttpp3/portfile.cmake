vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO eclipse/paho.mqtt.cpp
  REF 5e0d1bf37b4826d680ec066ec42afd133851a681
  SHA512 bcf36ab01e00959093b09d871bdd81d5c89b865357412b35da474092cf02d1501a2191d32b5ff7257afc50a5f12cfe4e5229b976c617da83ad3e5477add51731
  HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    "ssl" PAHO_WITH_SSL
)

# Link with 'paho-mqtt3as' library
set(PAHO_C_LIBNAME paho-mqtt3as)

# Setting the library path
if (NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "release")
  set(PAHO_C_LIBRARY_PATH "${CURRENT_INSTALLED_DIR}/lib")
else()
  set(PAHO_C_LIBRARY_PATH "${CURRENT_INSTALLED_DIR}/debug/lib")
endif()

# Setting the include path where MqttClient.h is present
set(PAHO_C_INC "${CURRENT_INSTALLED_DIR}/include")


# NOTE: the Paho C++ cmake files on Github are problematic.
# It uses two different options PAHO_BUILD_STATIC and PAHO_BUILD_SHARED instead of just using one variable.
# Unless the open source community cleans up the cmake files, we are stuck with setting both of them.
if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  set(PAHO_MQTTPP3_STATIC ON)
  set(PAHO_MQTTPP3_SHARED OFF)
  set(PAHO_C_LIB "${PAHO_C_LIBRARY_PATH}/${PAHO_C_LIBNAME}")
  set(PAHO_OPTIONS -DPAHO_MQTT_C_LIBRARIES=${PAHO_C_LIB})
else()
  set(PAHO_MQTTPP3_STATIC OFF)
  set(PAHO_MQTTPP3_SHARED ON)
  set(PAHO_OPTIONS)
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DPAHO_BUILD_STATIC=${PAHO_MQTTPP3_STATIC}
    -DPAHO_BUILD_SHARED=${PAHO_MQTTPP3_SHARED}
    -DPAHO_MQTT_C_INCLUDE_DIRS=${PAHO_C_INC}
    ${FEATURE_OPTIONS}
    ${PAHO_OPTIONS}
)

# Run the build, copy pdbs and fixup the cmake targets
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME PahoMqttCpp CONFIG_PATH "lib/cmake/PahoMqttCpp")

# Remove the include and share folders in debug folder
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

# Add copyright
file(INSTALL "${SOURCE_PATH}/about.html" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
