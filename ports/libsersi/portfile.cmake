vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO crhowell3/libsersi
  REF "v${VERSION}"
  SHA512 f8cd84e12a14d6c9dc424c176b3e0536293cfa96f4cb03f7e4c9008ce6272b70284179f16dca5f5fb82c4cad9003a16ed2639bcd52f18f39b9587cd63075e188
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DINSTALL_INCLUDE_DIR=include
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libsersi)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
