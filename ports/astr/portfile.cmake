vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO a4z/astr
  REF "${VERSION}"
  SHA512 f5a16e1e33a28d475fc6b70a406d25a507d6e3fcc76bbe382193993ace9491ec60605e918aa0f986aebc1d22bdbfc2d44f0dcb4e1378ec1683d9109cf2a3d255
  HEAD_REF main
)


vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
      -DFETCH_DOCTEST=OFF
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

configure_file("${CMAKE_CURRENT_LIST_DIR}/usage" "${CURRENT_PACKAGES_DIR}/share/${PORT}/usage" COPYONLY)

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
