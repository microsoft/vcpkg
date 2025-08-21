# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO pulzed/mINI
  REF ${VERSION}
  SHA512 d78ea8f57efe2cfa5c6cfa3b98681bc7f3fdd64b8b444b0b5a68a53888f5af54344ebfa73bf98f93690ca7f740e9d7568b9bee9aa286579c9280185d2874d5ee
  HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/src/mini/ini.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mini")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
