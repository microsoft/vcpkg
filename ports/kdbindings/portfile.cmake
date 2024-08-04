vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KDAB/KDBindings
  REF "v${VERSION}"
  SHA512 b66403ad4eecc5e8216600d67f29260eb9981f0b93517fa1a85106a52be4b3ffcd482d1dda6cdc5993f46ffa6cd0e10513cd7ce1fec3dee72ec9d50fc5887a46
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
