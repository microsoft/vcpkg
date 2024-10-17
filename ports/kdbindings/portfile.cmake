vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO KDAB/KDBindings
  REF "v${VERSION}"
  SHA512 a1a672cdf8b51d12bd8dea2feb0aae310914874012edbf91f66a0020682e8b7f525e4000ff41102b056f4fca968f0bca021d28eefd81a52d1dfb007afb62ad4c
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
