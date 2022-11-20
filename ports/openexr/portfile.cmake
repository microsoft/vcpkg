if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  message(FATAL_ERROR "UWP build not supported")
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO openexr/openexr
  REF 918b8f543e81b5a1e1aca494ab7352ca280afc9e # v2.5.8
  SHA512 7c4a22779718cb1a8962d53d0817a0b3cba90fc9ad4c6469e845bdfbf9ae8be8e43905ad8672955838976caeffd7dabcc6ea9c1f00babef0d5dfc8b5e058cce9
  HEAD_REF master
  PATCHES
    0001-remove_find_package_macro.patch
    0002-fixup_cmake_exports_path.patch
    0003-fix-arm-intrin-detection-pr-1216.patch
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
    -DCMAKE_DEBUG_POSTFIX=_d
    -DPYILMBASE_ENABLE=FALSE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()
vcpkg_cmake_config_fixup(PACKAGE_NAME ilmbase CONFIG_PATH share/ilmbase)
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(
  TOOL_NAMES exrenvmap exrheader exrmakepreview exrmaketiled exrmultipart exrmultiview exrstdattr exr2aces
  AUTO_CLEAN
)
vcpkg_copy_pdbs()

if (VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
