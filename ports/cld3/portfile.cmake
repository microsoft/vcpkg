vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO google/cld3
  REF b48dc46512566f5a2d41118c8c1116c4f96dc661
  SHA512 c3650ffbf5855aaf04d03930f01c6efd76e1f2b2d47365348721f16531a14653ae5b3aff8fefa8e5fa1c769fdf1a9b441a88bc687f97f8c579b84f17c6984c9e
  HEAD_REF master
  PATCHES
      fix-install.patch
)

vcpkg_configure_cmake(
  SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

