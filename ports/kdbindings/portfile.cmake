vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KDAB/KDBindings
  REF bbf790fc94f3018781f32be53c6086aedc0f74ec
  SHA512 4303f8e73b376e851d40cab99b848788ae2aff00e0e4ec0006655d8ef9373eebe5e04f734e78037e257d7a5101739b912da9dab15bf1985f204b31224d9c53c5
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DKDBindings_TESTS=OFF
    -DKDBindings_EXAMPLES=OFF
    -DKDBindings_DOCS=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/KDBindings)

file(REMOVE_RECURSE
  "${CURRENT_PACKAGES_DIR}/debug/"
  "${CURRENT_PACKAGES_DIR}/lib/" 
)

file(INSTALL "${SOURCE_PATH}/LICENSES/MIT.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
