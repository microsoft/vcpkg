include(vcpkg_common_functions)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO webmproject/libwebp
  REF v1.0.2
  SHA512 27ca4e7c87d3114a5d3dba6801b5608207a9adc44d0fa62f7523d39be789d389d342d9db5e28c9301eff8fcb1471809c76680a68abd4ff97217b17dd13c4e22b
  HEAD_REF master
  PATCHES
    0001-build-fixes.patch
    0002-cmake-config-add-backwards-compatibility.patch
)

set(WEBP_BUILD_ANIM_UTILS OFF)
set(WEBP_BUILD_GIF2WEBP OFF)
set(WEBP_BUILD_IMG2WEBP OFF)
set(WEBP_BUILD_VWEBP OFF)
set(WEBP_BUILD_WEBPINFO OFF)
set(WEBP_BUILD_WEBPMUX OFF)
set(WEBP_BUILD_EXTRAS OFF)
set(WEBP_NEAR_LOSSLESS OFF)
if("all" IN_LIST FEATURES)
  set(WEBP_BUILD_ANIM_UTILS ON)
  set(WEBP_NEAR_LOSSLESS ON)
  set(WEBP_BUILD_GIF2WEBP ON)
  set(WEBP_BUILD_IMG2WEBP ON)
  set(WEBP_BUILD_VWEBP ON)
  set(WEBP_BUILD_WEBPINFO ON)
  set(WEBP_BUILD_WEBPMUX ON)
  set(WEBP_BUILD_EXTRAS ON)
endif()

vcpkg_configure_cmake(
  SOURCE_PATH ${SOURCE_PATH}
  PREFER_NINJA
  OPTIONS
    -DWEBP_ENABLE_SIMD:BOOL=ON
    -DWEBP_BUILD_ANIM_UTILS:BOOL=${WEBP_BUILD_ANIM_UTILS}
    -DWEBP_BUILD_CWEBP:BOOL=OFF
    -DWEBP_BUILD_DWEBP:BOOL=OFF
    -DWEBP_BUILD_GIF2WEBP:BOOL=${WEBP_BUILD_GIF2WEBP}
    -DWEBP_BUILD_IMG2WEBP:BOOL=${WEBP_BUILD_IMG2WEBP}
    -DWEBP_BUILD_VWEBP:BOOL=${WEBP_BUILD_VWEBP}
    -DWEBP_BUILD_WEBPINFO:BOOL=${WEBP_BUILD_WEBPINFO}
    -DWEBP_BUILD_WEBPMUX:BOOL=${WEBP_BUILD_WEBPMUX}
    -DWEBP_BUILD_EXTRAS:BOOL=${WEBP_BUILD_EXTRAS}
    -DWEBP_BUILD_WEBP_JS:BOOL=OFF
    -DWEBP_NEAR_LOSSLESS:BOOL=${WEBP_NEAR_LOSSLESS}
    -DWEBP_ENABLE_SWAP_16BIT_CSP:BOOL=OFF
  OPTIONS_DEBUG
    -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_copy_pdbs()
vcpkg_fixup_cmake_targets(CONFIG_PATH "share/WebP/cmake/" TARGET_PATH "share/WebP/")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

if("all" IN_LIST FEATURES)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/get_disto.exe)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/gif2webp.exe)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/img2webp.exe)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/vwebp.exe)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/vwebp_sdl.exe)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/webpinfo.exe)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/webpmux.exe)
  file(REMOVE ${CURRENT_PACKAGES_DIR}/debug/bin/webp_quality.exe)
  file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools/libwebp/)
  file(RENAME ${CURRENT_PACKAGES_DIR}/bin/get_disto.exe ${CURRENT_PACKAGES_DIR}/tools/libwebp/get_disto.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/bin/gif2webp.exe ${CURRENT_PACKAGES_DIR}/tools/libwebp/gif2webp.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/bin/img2webp.exe ${CURRENT_PACKAGES_DIR}/tools/libwebp/img2webp.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/bin/vwebp.exe ${CURRENT_PACKAGES_DIR}/tools/libwebp/vwebp.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/bin/vwebp_sdl.exe ${CURRENT_PACKAGES_DIR}/tools/libwebp/vwebp_sdl.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/bin/webpinfo.exe ${CURRENT_PACKAGES_DIR}/tools/libwebp/webpinfo.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/bin/webpmux.exe ${CURRENT_PACKAGES_DIR}/tools/libwebp/webpmux.exe)
  file(RENAME ${CURRENT_PACKAGES_DIR}/bin/webp_quality.exe ${CURRENT_PACKAGES_DIR}/tools/libwebp/webp_quality.exe)
  vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/libwebp)
endif()

file(COPY ${SOURCE_PATH}/COPYING DESTINATION ${CURRENT_PACKAGES_DIR}/share/libwebp)
file(RENAME ${CURRENT_PACKAGES_DIR}/share/libwebp/COPYING ${CURRENT_PACKAGES_DIR}/share/libwebp/copyright)
