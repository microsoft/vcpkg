include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO eclipse/paho.mqtt.c
  REF 9f715d0862a8e16099b5837c4e53a1bf6a6a0675
  SHA512 3ab5e25bfe303f51485696248e78a8a10f20c0e69b7ea6016165a97d61172336e8fbe5b9d059ae546357bace9f3adb8e2026643b61a6af82fae448a024e51d21
  HEAD_REF master
  PATCHES
         remove_compiler_options.patch
         fix-install-path.patch
         fix-static-build.patch
         fix-unresolvedsymbol-arm.patch
         export-cmake-targets.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" PAHO_BUILD_STATIC)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS -DPAHO_WITH_SSL=TRUE -DPAHO_BUILD_STATIC=${PAHO_BUILD_STATIC} -DPAHO_ENABLE_TESTING=FALSE
)

vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH share/eclipse-paho-mqtt-c TARGET_PATH share/eclipse-paho-mqtt-c)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(RENAME ${CURRENT_PACKAGES_DIR}/share/paho-mqtt/README.md ${CURRENT_PACKAGES_DIR}/share/paho-mqtt/readme)
file(INSTALL ${SOURCE_PATH}/about.html DESTINATION ${CURRENT_PACKAGES_DIR}/share/paho-mqtt RENAME copyright)
