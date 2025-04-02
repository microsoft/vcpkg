# Header-only library
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO pulzed/mINI
  REF ${VERSION}
  SHA512 9b40a380c0a1eb5480840e19ccad75ae548101114bdd4b1589566cf6c90986447ba71cf7763b7e7e2124cfc665f92805b1c8620fd58bf4dba4cedda09c612c50
  HEAD_REF master
)

file(INSTALL "${SOURCE_PATH}/src/mini/ini.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include/mini")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
