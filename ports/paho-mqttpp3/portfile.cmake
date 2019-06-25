include(vcpkg_common_functions)

# Download from Github
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO eclipse/paho.mqtt.cpp
  REF v1.0.1
  SHA512 be612197fae387b9f1d8f10944d451ec9e7ebec6045beed365e642089c0a5fde882ed5c734f2b46a5008f98b8445a51114492f0f36fdc684b8a8fe4b71fe31a4
  HEAD_REF master
)

# If SSL is defined as part of the feature list, we set that feature ON
if (openssl IN_LIST FEATURES)
  # Use OpenSSL support
  set(PAHO_WITH_SSL ON)
  # Link with 'paho-mqtt3as.lib'
  set(PAHO_C_LIBNAME paho-mqtt3as)
else()
  # Do not use OpenSSL support
  set(PAHO_WITH_SSL OFF)
  # Link with 'paho-mqtt3a.lib'
  set(PAHO_C_LIBNAME paho-mqtt3a)
endif()


# Setting the library path
set(PAHO_C_LIBRARY_PATH "${CURRENT_INSTALLED_DIR}/lib")
# Setting the include path where MqttClient.h is present
set(PAHO_C_INC "${CURRENT_INSTALLED_DIR}/include/paho-mqtt")

# OS dependent cmake generator
if (WIN32)
  # Paho-Mqtt CPP doesn't work well with Ninja. Best is to generate using NMake Makefiles
  set(PAHO_CMAKE_GENERATOR "NMake Makefiles")
else()
  # This is *nix setup. Use Ninja here
  set(PAHO_CMAKE_GENERATOR "Ninja")
endif()

# Debug Status message display before configuring
# It is commented out during release, if anyone wants to debug, you are more than welcome to uncomment it
message("# Paho MQTT C++ build parameters: ")
message("  - Static/Shared: ${VCPKG_LIBRARY_LINKAGE}")
message("  - OpenSSL Support: ${PAHO_WITH_SSL}")
message("  - Paho C linkage: ${PAHO_C_LIBNAME}")

# Check if we are building 'static' or 'shared' library
if (VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  # NOTE: the Paho C++ cmake files on Github are problematic. 
  # It uses two different options PAHO_BUILD_STATIC and PAHO_BUILD_SHARED instead of just using one variable.
  # Unless the open source community cleans up the cmake files, we are stuck with setting both of them.
  set(PAHO_MQTTPP3_STATIC ON)
  set(PAHO_MQTTPP3_SHARED OFF)
  # Setting the library name only for static linkage
  set(PAHO_C_LIB "${PAHO_C_LIBRARY_PATH}/${PAHO_C_LIBNAME}")
  # Configure using cmake for building
  # Note: If we use static linkage, for some odd reason in Windows builds, the Paho MQTT C++ project cmake files
  # cannot find the PAHO_MQTT_C_LIBRARIES using find_library(). Therefore, we have to specify the exact path here.  
  vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}                      # Source path
    PREFER_NINJA                                    # Prefer to use Ninja for building
    GENERATOR ${PAHO_CMAKE_GENERATOR}               # Use the appropriate cmake generator
    OPTIONS                                         # here are the build options for static builds
      -DPAHO_BUILD_STATIC=${PAHO_MQTTPP3_STATIC}    #  -DPAHO_BUILD_STATIC=ON
      -DPAHO_BUILD_SHARED=${PAHO_MQTTPP3_SHARED}    #  -DPAHO_BUILD_SHARED=OFF
      -DPAHO_WITH_SSL=${PAHO_WITH_SSL}              #  -DPAHO_WITH_SSL=based of ssl feature enabled
      -DCMAKE_PREFIX_PATH=${PAHO_C_LIBRARY_PATH}    #  -DCMAKE_PREFIX_PATH=path to Paho MQTT C library
      -DPAHO_MQTT_C_LIBRARIES=${PAHO_C_LIB}         #  -DPAHO_MQTT_C_LIBRARIES=the library name to link with
      -DPAHO_MQTT_C_INCLUDE_DIRS=${PAHO_C_INC}      #  -DPAHO_MQTT_C_INCLUDE_DIRS=the path where the Paho MQTT C header files resides
  )
else()
  # NOTE: the Paho C++ cmake files on Github are problematic. 
  # It uses two different options PAHO_BUILD_STATIC and PAHO_BUILD_SHARED instead of just using one variable.
  # Unless the open source community cleans up the cmake files, we are stuck with setting both of them.
  set(PAHO_MQTTPP3_STATIC OFF)
  set(PAHO_MQTTPP3_SHARED ON)
  # Configure using cmake for building
  # Note: We do not have to pass the PAHO_MQTT_C_LIBRARIES here
  vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}                      # Source path
    PREFER_NINJA                                    # Prefer to use Ninja for building
    GENERATOR ${PAHO_CMAKE_GENERATOR}               # Use the appropriate cmake generator
    OPTIONS                                         # Here are the build options for dynamic/shared builds
      -DPAHO_BUILD_STATIC=${PAHO_MQTTPP3_STATIC}    #  -DPAHO_BUILD_STATIC=OFF
      -DPAHO_BUILD_SHARED=${PAHO_MQTTPP3_SHARED}    #  -DPAHO_BUILD_SHARED=ON
      -DPAHO_WITH_SSL=${PAHO_WITH_SSL}              #  -DPAHO_WITH_SSL=based of ssl feature enabled
      -DCMAKE_PREFIX_PATH=${PAHO_C_LIBRARY_PATH}    #  -DCMAKE_PREFIX_PATH=path to Paho MQTT C library
      -DPAHO_MQTT_C_INCLUDE_DIRS=${PAHO_C_INC}      #  -DPAHO_MQTT_C_INCLUDE_DIRS=the path where the Paho MQTT C header files resides
  )
endif()

# Run the build, copy pdbs and fixup the cmake targets
vcpkg_install_cmake()
vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH "lib/cmake/PahoMqttCpp")

# Remove the include and share folders in debug folder
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Add copyright
file(INSTALL ${SOURCE_PATH}/about.html DESTINATION ${CURRENT_PACKAGES_DIR}/share/paho-mqttpp3 RENAME copyright)

# Add this package as a module
vcpkg_test_cmake(PACKAGE_NAME paho-mqttpp3 MODULE)
