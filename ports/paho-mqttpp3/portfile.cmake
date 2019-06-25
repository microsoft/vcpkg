include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO eclipse/paho.mqtt.cpp
  REF v1.0.1
  SHA512 be612197fae387b9f1d8f10944d451ec9e7ebec6045beed365e642089c0a5fde882ed5c734f2b46a5008f98b8445a51114492f0f36fdc684b8a8fe4b71fe31a4
  HEAD_REF master
)

if (PAHO_WITH_SSL)
  set(PAHO_C_LIBNAME paho-mqtt3as)
else()
  set(PAHO_C_LIBNAME paho-mqtt3a)
endif()

set(PAHO_C_LIBRARY_PATH "${CURRENT_INSTALLED_DIR}/lib")
set(PAHO_C_INC "${CURRENT_INSTALLED_DIR}/include/paho-mqtt")
set(PAHO_C_LIB "${PAHO_C_LIBRARY_PATH}/${PAHO_C_LIBNAME}")

if (WIN32)
  # This is windows setup
  set(PAHO_CMAKE_GENERATOR "NMake Makefiles")
else()
  # This is linux setup
  set(PAHO_CMAKE_GENERATOR "Ninja")
endif()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  set(PAHO_MQTTPP3_STATIC ON)
  set(PAHO_MQTTPP3_SHARED OFF)
  vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    GENERATOR ${PAHO_CMAKE_GENERATOR}
    OPTIONS
      -DPAHO_BUILD_STATIC=${PAHO_MQTTPP3_STATIC}
      -DPAHO_BUILD_SHARED=${PAHO_MQTTPP3_SHARED}
      -DPAHO_WITH_SSL=${PAHO_WITH_SSL}
      -DCMAKE_PREFIX_PATH=${PAHO_C_LIBRARY_PATH}
      -DPAHO_MQTT_C_LIBRARIES=${PAHO_C_LIB}
      -DPAHO_MQTT_C_INCLUDE_DIRS=${PAHO_C_INC}
  )
else()
  set(PAHO_MQTTPP3_STATIC OFF)
  set(PAHO_MQTTPP3_SHARED ON)
  vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    GENERATOR ${PAHO_CMAKE_GENERATOR}
    OPTIONS
      -DPAHO_BUILD_STATIC=${PAHO_MQTTPP3_STATIC}
      -DPAHO_BUILD_SHARED=${PAHO_MQTTPP3_SHARED}
      -DPAHO_WITH_SSL=${PAHO_WITH_SSL}
      -DCMAKE_PREFIX_PATH=${PAHO_C_LIBRARY_PATH}
      -DPAHO_MQTT_C_INCLUDE_DIRS=${PAHO_C_INC}
  )
endif()

vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/PahoMqttCpp")

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${SOURCE_PATH}/about.html DESTINATION ${CURRENT_PACKAGES_DIR}/share/paho-mqttpp3 RENAME copyright)

vcpkg_test_cmake(PACKAGE_NAME paho-mqttpp3 MODULE)
