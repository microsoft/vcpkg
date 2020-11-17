vcpkg_fail_port_install(ON_TARGET "OSX" "Linux")

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO xiph/speex
  REF Speex-1.2.0
  SHA512  612dfd67a9089f929b7f2a613ed3a1d2fda3d3ec0a4adafe27e2c1f4542de1870b42b8042f0dcb16d52e08313d686cc35b76940776419c775417f5bad18b448f
  HEAD_REF master
  PATCHES
    0001-make-pkg-config-lib-name-configurable.patch
)

file(COPY ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt DESTINATION ${SOURCE_PATH})

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS_DEBUG -DDISABLE_INSTALL_HEADERS=ON
)

vcpkg_install_cmake()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
  file(READ "${CURRENT_PACKAGES_DIR}/include/speex/speex.h" _contents)
  string(REPLACE "extern const SpeexMode" "__declspec(dllimport) extern const SpeexMode" _contents "${_contents}")
  file(WRITE "${CURRENT_PACKAGES_DIR}/include/speex/speex.h" "${_contents}")
endif()

vcpkg_fixup_pkgconfig()

file(INSTALL ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
