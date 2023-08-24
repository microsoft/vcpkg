include("${CMAKE_CURRENT_LIST_DIR}/vcpkg_find_optix.cmake")

vcpkg_find_optix(
  OUT_OPTIX_DIR OPTIX_DIR
  OUT_OPTIX_VERSION OPTIX_VERSION
)

file(COPY "${OPTIX_DIR}/include/" DESTINATION "${SOURCE_PATH}")
file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
  PACKAGE_NAME unofficial-${PORT}
  CONFIG_PATH share/unofficial-${PORT}
)

file(INSTALL "${VCPKG_ROOT_DIR}/LICENSE.txt" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)