# Header-only library
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO oir/barkeep
  REF "v${VERSION}"
  SHA512 9c7c43c61a6b694f7cef95fb19376ffb0980ce851a8e73c6c0320e726dc03d8e5c51b8e9f7940487003876b85195f8ac4351cd14aef8c7171b4c36e0a64634a6
  HEAD_REF main
)

file(INSTALL "${SOURCE_PATH}/barkeep" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
