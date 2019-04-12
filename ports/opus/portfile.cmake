include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH
  SOURCE_PATH
  REPO
  xiph/opus
  REF
  f9d3d432d135253357ba457ecd0e4f68f12a4584
  SHA512
  9d77d063e0215c4f4e46b044d2f51106b3a599aeab7b1b788efa1fc79d0d2bc7780adafef6ffe6d3276f24223490898aa695cbbe36df174da9ba2317b21cb369
  HEAD_REF
  master)

vcpkg_configure_cmake(SOURCE_PATH ${SOURCE_PATH} PREFER_NINJA)
vcpkg_install_cmake()
vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/Opus)
vcpkg_copy_pdbs()

file(INSTALL
     ${SOURCE_PATH}/COPYING
     DESTINATION
     ${CURRENT_PACKAGES_DIR}/share/opus
     RENAME copyright)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/lib/cmake
                    ${CURRENT_PACKAGES_DIR}/lib/cmake
                    ${CURRENT_PACKAGES_DIR}/debug/include)
