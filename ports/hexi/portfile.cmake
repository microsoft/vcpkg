# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO EmberEmu/Hexi
  REF "v${VERSION}"
  SHA512 2ec2700891baae74873bec62bbd1267deb89334ff121e9a1e5903f90c0b04827ec003f3b15baadc81c7dc3d6c80c65dd1714ab92fd3054a5c48c5fff0a7ecfbb
  HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/single_include/hexi.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/hexi")
file(INSTALL "${SOURCE_PATH}/single_include/hexi_fwd.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/hexi")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/LICENSE-MIT")
