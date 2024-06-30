vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO crhowell3/libdis6
  REF "${VERSION}"
  SHA512 695f30882fc46772c017086f736d94884b53787b592ff2aa19ed7d8f190d005472f6c6f03f64b309dda50ec0c332486eab58b61501981d1aff4f36d1f1953df7
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DINSTALL_INCLUDE_DIR=include
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libdis6-${LIBDIS6_VERSION})
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
