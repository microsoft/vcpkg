vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO tree-sitter/tree-sitter
  REF "v${VERSION}"
  SHA512 a42d744f6e1db7c7c842804f3435b87ccb5d0df2363a18eee38353f12f18c8cf0c6211bf0225fd5f2c0431ca8531aa4ddd73d87d42b80fa35c3c701cae2d7856
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
