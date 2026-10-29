vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO twig-energy/stronk
  REF v${VERSION}
  SHA512 7633b189fa4f47cc6cb9d3d3a2030f0bb0aa85842abbd5ba5fa0ee63120012bb7adb5c2563505ae582f390f5848a0fb829214b07ab6d9afaa9a80db471ec06c6
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS -DCMAKE_INSTALL_INCLUDEDIR:STRING=include
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
