vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO upa-url/upa
  REF "v${VERSION}"
  SHA512 84258353972a73674395b98a26f151596588c4f52d7892cb17233dd8aa1f0ca2831fa46533d1d6f151780ab7aa101202f48cd811253d72f3e694248d478f76cb
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DUPA_BUILD_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME "upa" CONFIG_PATH "lib/cmake/upa")
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
