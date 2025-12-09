# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO iboB/itlib
  REF "v${VERSION}"
  SHA512 1fe8da43b29b56b555f474ba5f57629a76d7c42e10359fa4313e33bb8c1ec02db5365e82d18a858ed8de33b959ed451e4fbfbd23d179d8e4da5f1832da8ef127
  HEAD_REF master
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/include/itlib" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
