vcpkg_cmake_configure(
  SOURCE_PATH "${CMAKE_CURRENT_LIST_DIR}"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(
  PACKAGE_NAME provider
  CONFIG_PATH lib/cmake/provider
)

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

file(WRITE "${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright" "This test port is part of vcpkg.")
