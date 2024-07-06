vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nodejs/node-api-headers
  REF "v${VERSION}"
  SHA512 70871b8fd1fc16f3f525953fd229ceff99110fb604f039e35e44f21d74aa9d50d2d3be1eadc5700bf576fd27e750c71868b273277858195fb6c5739672d4455e
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
