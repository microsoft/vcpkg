vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO tree-sitter/tree-sitter
  REF ccd6bf554d922596ce905730d98a77af368bba5c #v0.20.6
  SHA512 ab7eeecafc9d7d17093e25479903fa8c77a84ce4c3a41d737d49bcf9348ab6cc55cf3d6cce0229781292c2b05342fbf45641e40545ea3fde09e441e02f2cdb83
  HEAD_REF master
  PATCHES pkgconfig.patch
)

# currently not supported upstream
if(VCPKG_TARGET_IS_WINDOWS)
  vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}/lib")

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}/lib"
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(PACKAGE_NAME "unofficial-tree-sitter")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

# Handle copyright
file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
