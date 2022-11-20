# Download from Github
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO eclipse/paho.mqtt.cpp
  REF 33921c8b68b351828650c36816e7ecf936764379 #v1.2.0
  SHA512 3f4a91987e0106e50e637d8d4fb13a4f8aca14eea168102664fdcebd1260609434e679f5986a1c4d71746735530f1b72fc29d2ac05cb35b3ce734a6aab1a0a55
  HEAD_REF master
  PATCHES
    fix-dependency.patch
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
