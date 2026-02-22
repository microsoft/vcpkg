# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO iboB/itlib
  REF "v${VERSION}"
  SHA512 30137dffdbb9f708ca8e04c0d04e7af7f4d640cd9cd72ee99a40ca81d3f243c5bc1574aa4ab3cdb6eee8b1f11ada5787ac66aa08cc30e9de0d569d6d43d4cfd4
  HEAD_REF master
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/include/itlib" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
