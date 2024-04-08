vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO alicevision/AliceVision
  REF v3.2.0
  SHA512  448e20b2bb6623034ab89ea56b0c7fdf09af34d7d0d47740590fa9cd9aa2b6864f3950c4e968d260c660a41a2f5877c10edf8cfd0dcdd18e58ce289b7336e9ec
  HEAD_REF master
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${options}
)

vcpkg_cmake_install()
#vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING.md")
