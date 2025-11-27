vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO twig-energy/stronk
  REF v${VERSION}
  SHA512 146630a8fbc91de92c56cbbb5bb8737a54997da155f52141b15c4b937c04b04b98e893b37a98a376c6aa7ddd57bb0847f8543188f9042846364e9bed6f617472
  HEAD_REF main
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
