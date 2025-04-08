# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO furfurylic/commata
  REF "v${VERSION}"
  SHA512 5ce3028b7bb854ce51d6cc7683b71a90e3758a7ceae03f1fba4fbfaa9b324907163f23e6330e87dc902a25fc2901f05c55be1aca34ada208b88898f1800e8858
  HEAD_REF master
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/include/commata" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
