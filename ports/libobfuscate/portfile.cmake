vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO adamyaxley/Obfuscate
  REF a46cd5d8bd09e44afb27f97cde842e9473a4fdf6
  SHA512 9be3df71cbec3819553d46a2ab7f613401f4b1ef6a2d3bff2f23fef6aec3ae6475cbfc3413d9be46b46e911f1ad8ffdb1a839b54da46ca0d152a07b6829a06c5
  HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/obfuscate.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
