vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nlohmann/fifo_map
  REF v${VERSION}
  SHA512 4f99e6dac74b3c390e9a03b9fea8521d4facd244f85f37206ebd8aa244295c21c9c145e22f80ad45d88325fd1b440d44bd654c829074e0c20b5ed8a62b88c9a7
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
