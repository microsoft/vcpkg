include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH
  SOURCE_PATH
  REPO
  xiph/opus
  REF
  e85ed7726db5d677c9c0677298ea0cb9c65bdd23
  SHA512
  a8c7e5bf383c06f1fdffd44d9b5f658f31eb4800cb59d12da95ddaeb5646f7a7b03025f4663362b888b1374d4cc69154f006ba07b5840ec61ddc1a1af01d6c54
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
