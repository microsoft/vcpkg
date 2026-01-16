# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO furfurylic/commata
  REF "v${VERSION}"
  SHA512 9204ff324113359c3f59f10cf24403bf6b18c44146715165f2b8886c852b909cdbd4f681ae82d6abd1c7ce1a1f68cea41c649154f8ec074811f36312e8c168e5
  HEAD_REF master
)

file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/include/commata" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
