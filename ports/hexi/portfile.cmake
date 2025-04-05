# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO EmberEmu/Hexi
  REF "v${VERSION}"
  SHA512 00292cdbdb78da204577e49f2517ceeabca6a636a670944b234342dea49548311481ad096d6e9423fc0f0956f8d644162f447595269ecef1c6e6242a2c0c9588
  HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/single_include/hexi.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/hexi")
file(INSTALL "${SOURCE_PATH}/single_include/hexi_fwd.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/hexi")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/LICENSE-MIT")
