# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mackron/miniaudio
  REF "${VERSION}"
  SHA512 0c67ff7d9112409fea5af7756c1bc14bca4acfa45a97896ea339cdab228ac3dcc843c492e6da9dc75d4cd6f6b795ee80fe3ad9c4c746d7db691b1216f86e456d
  HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/miniaudio.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
