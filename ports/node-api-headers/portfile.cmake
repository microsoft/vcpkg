vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nodejs/node-api-headers
  REF "v${VERSION}"
  SHA512 e80d9b8cc2d96929a6d73fc1e5bcfbf6d585bef114946f939b93195aefb91bf8e6ef8720625394d344636626fd74548db71ff178f9f529ab5b20db980f09b197
  HEAD_REF main
)

if(VCPKG_TARGET_IS_WINDOWS)
  file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
  vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
  vcpkg_cmake_install()
endif()

file(INSTALL "${SOURCE_PATH}/include" DESTINATION "${CURRENT_PACKAGES_DIR}/include" RENAME "node")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-${PORT}-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake" @ONLY)
