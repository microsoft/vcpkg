# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mackron/miniaudio
  REF "${VERSION}"
  SHA512 35f64a5888e9d83c6fb5bb3c0bcdce27499f021aa9118b64f03b5fa8b04736547d804d7e37acf9687b203e0e4282b4741971752e5d81f64e82e39a903e76baf6
  HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/miniaudio.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
