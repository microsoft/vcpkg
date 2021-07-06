vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO eclipse/paho.mqtt.c
  REF 3b7ae6348bc917d42c04efa962e4868c09bbde9f # v1.3.9
  SHA512 73c10b7da7aa228100511db280ae56484cb8c42b8f0cfafb2fa3f6e230b4bb1d6b3611aa9219736a0baa9d7de0baf802dd70dbf308077f1a745bd61a67a797c7
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
