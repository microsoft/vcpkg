vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO nodejs/node-api-headers
  REF "v${VERSION}"
  SHA512 68e1a689482a1108fcc3d7477e38d8ca19efe7eb1ee8bc2db540bc4245ecfe067b257e4aa775e358265846bfabb72703432cc190ccbeddd0194eaec1f099d31b
  HEAD_REF main
)

if(VCPKG_TARGET_IS_WINDOWS)
  file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
  vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}")
  vcpkg_cmake_install()
endif()

file(INSTALL "${SOURCE_PATH}/include/js_native_api.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/include/js_native_api_types.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/include/node_api.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")
file(INSTALL "${SOURCE_PATH}/include/node_api_types.h" DESTINATION "${CURRENT_PACKAGES_DIR}/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

configure_file("${CMAKE_CURRENT_LIST_DIR}/unofficial-${PORT}-config.cmake.in" "${CURRENT_PACKAGES_DIR}/share/unofficial-${PORT}/unofficial-${PORT}-config.cmake" @ONLY)
