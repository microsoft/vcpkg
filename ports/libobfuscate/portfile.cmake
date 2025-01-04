vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO adamyaxley/Obfuscate
  REF a46cd5d8bd09e44afb27f97cde842e9473a4fdf6
  SHA512 2db334f82be627befbe4c459e0048bff13ec5e677e520185c72cf9e77d3fa8376cc00a5a10065ec19f6a5d4379b35613da5912ead63a3d9b47b1b17797bcc262
  HEAD_REF master
)

file(INSTALL ${SOURCE_PATH}/obfuscate.h DESTINATION ${CURRENT_PACKAGES_DIR}/include)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
