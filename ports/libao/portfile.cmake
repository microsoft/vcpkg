if(VCPKG_TARGET_IS_WINDOWS)
  list(APPEND PATCHES "0001-windows-build-patch.patch")
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO xiph/libao
  REF 1.2.2
  SHA512  d2736d25b60862e7d7469611ce31b1df40a4366ab160e2ff1b46919ae91692d1596c8468e4f016303b306fc3ac1bddc7b727f535a362f403c3fe7c6532e9045a
  HEAD_REF master
  PATCHES ${PATCHES}
)


if(VCPKG_TARGET_IS_WINDOWS)
  file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
  
  vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
  )
  vcpkg_cmake_install()
else()
  vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
    OPTIONS --disable-binaries # no example programs (require libogg)
  )
  vcpkg_install_make()

  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
endif()

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
