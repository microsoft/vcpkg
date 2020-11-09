vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO eclipse/paho.mqtt.c
  REF 153dfd3a4a1d510697c5d55e169fa158db16e04a # v1.3.5
  SHA512 231978c9159b85f4b189574bfe982d99ef75aabbb616bf88f251e4fe1797fd89156b4090c6d7e05703fe9394b3243a906196cb54dab3044727b03bbc64a63e5b
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
