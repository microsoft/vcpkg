include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO eclipse/paho.mqtt.c
  REF 7691387b6cd714443f8d4906ca94d503e19a8773
  SHA512 daaae7200faa7b601749f37849e74b2252d483f5118966b9af0c272c677974c4512f6b57c1753ca722e328b0e3e3bd782a5062b9fd325910310569faab3d232d
  HEAD_REF master
  PATCHES
         remove_compiler_options.patch
         fix-install-path.patch
         fix-static-build.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" PAHO_BUILD_STATIC)

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS -DPAHO_WITH_SSL=TRUE -DPAHO_BUILD_STATIC=${PAHO_BUILD_STATIC} -DPAHO_ENABLE_TESTING=FALSE
)

vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(RENAME ${CURRENT_PACKAGES_DIR}/share/paho-mqtt/README.md ${CURRENT_PACKAGES_DIR}/share/paho-mqtt/readme)
file(INSTALL ${SOURCE_PATH}/about.html DESTINATION ${CURRENT_PACKAGES_DIR}/share/paho-mqtt RENAME copyright)
