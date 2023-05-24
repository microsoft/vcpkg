vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO David-Haim/concurrencpp
  REF v.${VERSION}
  SHA512 51e8ba898256165ef5173a098e804121ae0d1212b5d83e6356a34c72dc3d66849f7382e1f35f5ec34718425563faf1795675c6eeb5374dd660a65800e8318a1f
  HEAD_REF master
  PATCHES
    fix-include-path.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/concurrencpp-${VERSION}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.txt")
