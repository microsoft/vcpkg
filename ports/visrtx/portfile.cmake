vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO NVIDIA/VisRTX
  REF next_release # "v${VERSION}"
  SHA512 f3609eb2c70ed6fd240d4d01d840c74c142e03211e822f351874200813bb3b8cde3d32016c21cc9bed29201dc99174db59b5d08c772bccba354023eb9972e2e8 # c4257c563594a43cdb95466947e329882105e005907c2ee638d0a9607dfd76e9c1c0da70b2eb41b680516a4ccde5a6f039306a87e467cc12e1969cdf21007f44
  HEAD_REF main
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
