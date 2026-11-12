set(VCPKG_BUILD_TYPE release) # header-only port

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mackron/miniaudio
  REF "${VERSION}"
  SHA512 5b5031bc41e57c8f46a3a27c240bc69a7e2e3180d914329c0b73122ad7d678a77dfb5e5018042ef36ccd25bf00151802908dc8166c906edbf739029bf6017c29
  HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/miniaudio.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
