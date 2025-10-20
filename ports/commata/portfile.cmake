# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO furfurylic/commata
  REF "v${VERSION}"
  SHA512 1c4ca9f37ea629289b6067a2fd6ac4ce61205c03fc1a2e9460cac1c139e46b14fa11a772bff217302ed847cf2043ad2f1af4ebc8962811dc57360e20cbd708ce
  HEAD_REF master
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/include/commata" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
