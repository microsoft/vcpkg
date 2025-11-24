vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KDAB/KDBindings
  REF "v${VERSION}"
  SHA512 6316f2a8009e47d513fc85d7fa7ad135daf1495ce392aa7852601ae62a09dede022cfa05d9d990041e1abab08b577c86a5ac548128a550c0e1a4bb0a295818e9
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

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSES/MIT.txt")
