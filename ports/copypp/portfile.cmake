vcpkg_from_github(
  OUT_SOURCE_PATH
  SOURCE_PATH
  REPO
  i-curve/copypp
  REF
  0c54fe4175064c0e5e545a725a851a050a430c67 
  SHA512
  cd20275b6c823df4dd2e27b0e7fa74094ac73d5e77b69cdeb5746a9943088daffee26f5e00b57f33d486e1b4afbf5f5c5a34dcab3faa53f35774f873cdc14d6d
  HEAD_REF
  main)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS "-DCOPYPP_TEST=OFF"
)

vcpkg_cmake_install()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/copypp)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib" "${CURRENT_PACKAGES_DIR}/debug/lib")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage"
     DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")