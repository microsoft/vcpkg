vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nlohmann/fifo_map
  REF v${VERSION}
  SHA512 302f32a2d5c7e134a29d45ded4c00c03114d21162715ad5c62f329d8a1df3242fd4f734e9770ec9bbf782285b3789eba1edcbfd3c9ccd1405aaa31134f71a944
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
