vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO eclipse/paho.mqtt.c
  REF 317fb008e1541838d1c29076d2bc5c3e4b6c4f53 # v1.3.8
  SHA512 065d850dbcd20144e7f5534d0cac30170c7f90b1cdca90f4eaaa6b7d69056d9e1bfe951ef34aa7e1a2d3bbc193e95a1526d4dee40ea2f243f3120620b577aacb
  HEAD_REF master
  PATCHES
         remove_compiler_options.patch
         fix-install-path.patch
         fix-unresolvedsymbol-arm.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" PAHO_BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" PAHO_BUILD_DYNAMIC)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DPAHO_WITH_SSL=TRUE
    -DPAHO_BUILD_SHARED=${PAHO_BUILD_DYNAMIC}
    -DPAHO_BUILD_STATIC=${PAHO_BUILD_STATIC}
    -DPAHO_ENABLE_TESTING=FALSE
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/eclipse-paho-mqtt-c TARGET_PATH share/eclipse-paho-mqtt-c)
vcpkg_copy_pdbs()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_copy_tools(TOOL_NAMES MQTTVersion AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

file(COPY ${SOURCE_PATH}/README.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/about.html DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
