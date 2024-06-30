vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO crhowell3/libdis6
  REF "v${VERSION}"
  SHA512 d8a678d6aac8ac3dbb214b0fdca7ee1e00de2bcc92537fc110ab849ffeb0c864edd7d882b0066c3c12633cc24153e9c7cdf1e30f5e4913fecc8387a3f8d099af
  HEAD_REF main
)

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    -DINSTALL_INCLUDE_DIR=include
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libdis6)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
