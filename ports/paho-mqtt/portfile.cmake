vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO eclipse/paho.mqtt.c
  REF d34c51214f4172f2e12bb17532c9f44f72a57dd4 # v1.3.1
  SHA512 184a8ace64bb967c63ac11a2476e6753d7aad39f93b290be030356841a8891edec6e0ac4b925089f2234a56f6da9c09c1a92023d3883fa785d986342bfee3972
  HEAD_REF master
  PATCHES
         remove_compiler_options.patch
         fix-install-path.patch
         fix-static-build.patch
         fix-unresolvedsymbol-arm.patch
         export-cmake-targets.patch
         fix-win-macro.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" PAHO_BUILD_STATIC)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DPAHO_WITH_SSL=TRUE
    -DPAHO_BUILD_STATIC=${PAHO_BUILD_STATIC}
    -DPAHO_ENABLE_TESTING=FALSE
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/eclipse-paho-mqtt-c TARGET_PATH share/eclipse-paho-mqtt-c)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

file(RENAME ${CURRENT_PACKAGES_DIR}/share/paho-mqtt/README.md ${CURRENT_PACKAGES_DIR}/share/${PORT}/readme)
file(INSTALL ${SOURCE_PATH}/about.html DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
