# Header-only library
set(VCPKG_BUILD_TYPE release)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO oir/barkeep
  REF "v${VERSION}"
  SHA512 b474bdae5e97b185daaf335193bf678e1dc57faa2000759f747a2c13e0a9e302f96927a81d8e26eb8227303b26148c2f0a005f984ea3271216416514fa14b9e1
  HEAD_REF main
)

file(INSTALL "${SOURCE_PATH}/barkeep" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
