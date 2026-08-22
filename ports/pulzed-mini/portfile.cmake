# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO pulzed/mINI
  REF ${VERSION}
  SHA512 6a905e4dda604ef5d1f36e2b1ec071296e3825748e73ee5aaaf8879d212a2dca3220f837a47330c4c41b9ef0d01db26ce33a33370c591baa8bf1589ce88fe58c
  HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/src/mini/ini.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mini")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
