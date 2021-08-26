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

vcpkg_configure_cmake(SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DCMAKE_DEBUG_POSTFIX=_d
    -DPYILMBASE_ENABLE=FALSE
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH share/ilmbase TARGET_PATH share/ilmbase)
vcpkg_fixup_cmake_targets()
vcpkg_fixup_pkgconfig()

file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exrenvmap${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exrheader${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exrmakepreview${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exrmaketiled${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exrmultipart${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exrmultiview${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exrstdattr${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/exr2aces${VCPKG_HOST_EXECUTABLE_SUFFIX})

file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/openexr/)
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exrenvmap${VCPKG_HOST_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openexr/exrenvmap${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exrheader${VCPKG_HOST_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openexr/exrheader${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exrmakepreview${VCPKG_HOST_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openexr/exrmakepreview${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exrmaketiled${VCPKG_HOST_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openexr/exrmaketiled${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exrmultipart${VCPKG_HOST_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openexr/exrmultipart${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exrmultiview${VCPKG_HOST_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openexr/exrmultiview${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exrstdattr${VCPKG_HOST_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openexr/exrstdattr${VCPKG_HOST_EXECUTABLE_SUFFIX})
file(RENAME ${CURRENT_PACKAGES_DIR}/bin/exr2aces${VCPKG_HOST_EXECUTABLE_SUFFIX} ${CURRENT_PACKAGES_DIR}/tools/openexr/exr2aces${VCPKG_HOST_EXECUTABLE_SUFFIX})
vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/openexr)

vcpkg_copy_pdbs()

if (VCPKG_CMAKE_SYSTEM_NAME OR VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

file(INSTALL ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/LICENSE.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
