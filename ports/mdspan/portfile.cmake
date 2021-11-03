vcpkg_from_github(
  OUT_SOURCE_PATH
  SOURCE_PATH
  REPO
  kokkos/mdspan
  REF
  9d1acac543053cbe6839273f550b1ece218e9696 # v0.1.0
  SHA512
  fcb75063e22367f830dee2b7ecbccb0c0682d03e5b8959f4c3a8d3ba5f3e259b7a44ce42ade999e4c39273c34adb286f69f2ca94ce15cfbe294184983880975f
  HEAD_REF
  stable)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH})

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/mdspan)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib"
     "${CURRENT_PACKAGES_DIR}/debug")

vcpkg_copy_pdbs()

file(
  INSTALL ${SOURCE_PATH}/LICENSE
  DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT}
  RENAME copyright)
