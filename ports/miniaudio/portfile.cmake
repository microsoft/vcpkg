# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO mackron/miniaudio
  REF "${VERSION}"
  SHA512 6027109fd6427eb52eea6535dded0f419d79d1a31a2bf4a1a11c1fb48485fa4e65cac04fb0b7c82811663ce86227e0527a49e681ce966934c0159ccbc1ad094c
  HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/miniaudio.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

# Handle copyright
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
