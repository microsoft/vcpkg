# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO furfurylic/commata
  REF "v${VERSION}"
  SHA512 72701ef3e3789a10401760f2c90d26975b5c6427a19a2a32928bc8a9725ce00bd62e5bc03eb0f231c16fb1aa2cef9910401004e77f8e9f734f8ad2e0293ed731
  HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/include/commata" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
