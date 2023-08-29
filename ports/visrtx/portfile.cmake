vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO NVIDIA/VisRTX
  REF "v${VERSION}"
  SHA512 2c4349bee5aeb9d985a2a03bfc95247ce8cb991c877b91729b3f43ac6e16151082f65a0b16b1acadf2bc2a55c87bfb0cf3c0c9fefe2520412620d98feec5a265
  HEAD_REF main
  PATCHES
    fix-dependencies.patch
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")
vcpkg_fixup_pkgconfig()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE 
  "${CURRENT_PACKAGES_DIR}/debug/include" 
  "${CURRENT_PACKAGES_DIR}/debug/share"
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
  file(REMOVE_RECURSE 
    "${CURRENT_PACKAGES_DIR}/bin" 
    "${CURRENT_PACKAGES_DIR}/debug/bin"
  )
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
