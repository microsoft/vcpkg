# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO furfurylic/commata
  REF "v${VERSION}"
  SHA512 286d28d65718e29903e3c0a15804514ad1fb0045880b0ec19f0beb9db997c0a22131c4cd4ec1263ee35edd8f44c3576fa43d75878d19f9fd2d4ddba652196994
  HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/include/commata" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
