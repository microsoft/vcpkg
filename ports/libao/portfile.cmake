set(NO_DLFCN )
if(VCPKG_TARGET_IS_WINDOWS)
  list(APPEND PATCHES "0001-windows-build-patch.patch")
  set(NO_DLFCN "ac_cv_header_dlfcn_h=no")
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
  set(ENV{LIBS} "-lwinmm -lksuser")
endif()

vcpkg_configure_make(
  SOURCE_PATH ${SOURCE_PATH}
  AUTOCONFIG
  OPTIONS  --disable-binaries
           ${NO_DLFCN}
)
vcpkg_install_make()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")


vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
