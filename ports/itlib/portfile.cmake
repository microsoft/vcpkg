# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO iboB/itlib
  REF "v${VERSION}"
  SHA512 9995b083cedde1883acd0f60cb6463dc1af21c0dde0b0c588db9ae311a8929c15c7d1c1853ab15ac79d77035ce3cef568eac1a0358b16b2015acf638c2281054
  HEAD_REF master
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/include/itlib" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
