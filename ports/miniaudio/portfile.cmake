# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mackron/miniaudio
  REF 9a7663496fc06f7a9439c752fd7666ca93328c20
  SHA512 ada4c52bdf91b7ce3530616f28adb50803e40d7b6d01a6c2d127211a1497a4fb99f6e3d2c37f5422bcad4c7ef99f916846c8c6ad05ac1b68756c0337b9720ad8
  HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/miniaudio.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
