# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO iboB/itlib
  REF "v${VERSION}"
  SHA512 2ab2b3395ad3f14ec01eaf7a4bf8740df4d3503c71bb150278359d0d6b3602e6569632709a5ce316af1798787aec6c869e44759b703aff8a1c924123be2a893c
  HEAD_REF master
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/include/itlib" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
