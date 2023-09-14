vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO jurihock/stftPitchShift
  HEAD_REF main
  REF v1.4.1
  SHA512 69e68af5baeb1bbeae440d2b2dc7a510a72b8b49cd9b23e0934eb8070d31c9a2e98759ea6d609f81caa3c57e1615cc50028dd13a9d04e82725a41da79175a868
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DVCPKG=ON
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
  CONFIG_PATH "lib/cmake/${PORT}"
)

file(
  INSTALL "${SOURCE_PATH}/LICENSE"
  DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}"
  RENAME copyright
)

file(
  REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include"
)
