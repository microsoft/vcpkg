# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO pulzed/mINI
  REF ${VERSION}
  SHA512 af29b0e59a2bed460a3a4e071932e0c01c017a57643c9414d360e17aa643bce476dc2941760a0cd904ec24483e67ee7f0df6029dc79254052c6c3c1d0941d4d0
  HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/src/mini/ini.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mini")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
