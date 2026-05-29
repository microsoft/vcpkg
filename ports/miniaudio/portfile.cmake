# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mackron/miniaudio
  REF "${VERSION}"
  SHA512 8cdfe5cd66dd84628430a24026b307c21158b4776492eec234c2ce3cf0da3ae26fe8162f3ed285502f6002fdf252ccb660f7c216e044e3c306b75b0997700b45
  HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/miniaudio.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
