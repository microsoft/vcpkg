# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO EmberEmu/Hexi
  REF "v${VERSION}"
  SHA512 25a02c79ad43cfe21bc306df3f9c2f64561b07f7eea70be9d59c4a76505a5b68805fbea29fe67052795bfc21daf5889c5bbc3e39ef561b993925cc96d2d17cfe
  HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/single_include/hexi.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/hexi")
file(INSTALL "${SOURCE_PATH}/single_include/hexi_fwd.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/hexi")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/LICENSE-MIT")
