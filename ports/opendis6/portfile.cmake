vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  OPTIONS
    -DINSTALL_INCLUDE_DIR=include
  REPO crhowell3/opendis6
  REF "${VERSION}"
  SHA512 f83e2dc8c3c06f420c88af35bc818561383760adb026548ce69f483568d87c1457dfbb3d25279d24bb2f08b8ff539f1ad3ed42db1963e1618f01b442d4ff791a
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/OpenDIS)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
