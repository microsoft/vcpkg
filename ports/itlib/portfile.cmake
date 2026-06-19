# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO iboB/itlib
  REF "v${VERSION}"
  SHA512 d4a687bbadb599c425036377b5d3c0a0187a0cda128addc282c06278e3acbca89c16607ff9c7c35b669a8ddacad9788bb392724dd98f76459e7cd72163748c5c
  HEAD_REF master
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/include/itlib" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
