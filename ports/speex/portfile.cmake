if(VCPKG_TARGET_IS_WINDOWS)
  list(APPEND PATCHES "0001-make-pkg-config-lib-name-configurable.patch")
endif()

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO xiph/speex
  REF Speex-1.2.0
  SHA512  612dfd67a9089f929b7f2a613ed3a1d2fda3d3ec0a4adafe27e2c1f4542de1870b42b8042f0dcb16d52e08313d686cc35b76940776419c775417f5bad18b448f
  HEAD_REF master
  PATCHES ${PATCHES}
)

if(VCPKG_TARGET_IS_WINDOWS)
  file(COPY "${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt" DESTINATION "${SOURCE_PATH}")
  
  vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
  )
  vcpkg_install_cmake()

  if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/speex/speex.h"
        "extern const SpeexMode"
        "__declspec(dllimport) extern const SpeexMode"
    )
  endif()
else()
  vcpkg_configure_make(
    SOURCE_PATH ${SOURCE_PATH}
    AUTOCONFIG
  )
  vcpkg_install_make()

  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
endif()

vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
