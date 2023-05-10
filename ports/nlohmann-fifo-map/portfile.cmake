vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nlohmann/fifo_map
  REF 0dfbf5dacbb15a32c43f912a7e66a54aae39d0f9
  SHA512 1e515d02ff49684dc8439ee1f3b9fbece3c727b6f669ee9a251eae8d8bf33eff0a36ab58829956a698cd9bfb757f9c6ade227d601197aa7b824c0584f48e181d
  HEAD_REF master
)

#make sure we don't use any integrated pre-built library nor any unnecessary CMake module
file(REMOVE_RECURSE "${SOURCE_PATH}/test")
file(REMOVE "${SOURCE_PATH}/CMakeLists.txt")

file(COPY "${CURRENT_PORT_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib")

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE.MIT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
