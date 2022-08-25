if (VCPKG_CMAKE_SYSTEM_NAME STREQUAL "WindowsStore")
  message(FATAL_ERROR "UWP build not supported")
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO openexr/openexr
  REF ed64d5467dee9763f28baf300f7699e6288b9f5f
  SHA512 549d37ed1ef4d1ff7e732d583f7213ee15c7f92625aea9fd65345e4c5b854902c02e5940d0692b1af5ae0a02abf46aaefea2662db2389d1b2fb4264a373baac2
  HEAD_REF master
  PATCHES
    0001-remove_find_package_macro.patch
    0002-fixup_cmake_exports_path.patch
    0003-remove_symlinks.patch
    0004-Fix-pkg-config-lib-suffix-for-cmake-debug-builds.patch  # https://github.com/AcademySoftwareFoundation/openexr/pull/1032
)

vcpkg_cmake_configure(SOURCE_PATH ${SOURCE_PATH}
  OPTIONS
    -DCMAKE_DEBUG_POSTFIX=_d
    -DPYILMBASE_ENABLE=FALSE
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup()
vcpkg_fixup_pkgconfig()

vcpkg_copy_tools(
  TOOL_NAMES exrenvmap exrheader exrmakepreview exrmaketiled exrmultipart exrmultiview exrstdattr exr2aces
  AUTO_CLEAN
)

vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/openexr)

vcpkg_copy_pdbs()

if (VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
