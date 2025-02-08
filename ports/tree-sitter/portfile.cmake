vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO tree-sitter/tree-sitter
  REF "v${VERSION}"
  SHA512 9861b18c7209e3c37d180a399bcae181cea46c4e58eff743ff6044ed0f2923ee838fa88993f1266272e07163748d5df1bef7d7dc6d8800e004e8af1227e489af
  HEAD_REF master
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
