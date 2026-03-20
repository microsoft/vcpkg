vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO twig-energy/stronk
  REF v${VERSION}
  SHA512 a86660dab08ad70426c01f6449cb777a6d05d528d7fbcbcf6c29f372327e412e46dc10f68f51049387de8e56fbf94ceba003f86091b09f054d8069b152cda900
  HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
