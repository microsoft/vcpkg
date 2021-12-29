vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO webmproject/libwebp
  REF 9ce5843dbabcfd3f7c39ec7ceba9cbeb213cbfdf # v1.2.1
  SHA512 43224caedb0d591ad1dd3872cd882c0fe255e24425f6da82fca212783ddb231326797a82ead0a1b8b15dc98db1cb05741e3a5e5131babbcc49a529a9f3253865
  HEAD_REF master
  PATCHES
    0001-build.patch
    0002-cmake-config-add-backwards-compatibility.patch
    0003-always-mux.patch #always build libwebpmux
    0004-add-missing-linked-library.patch
    0006-fix-dependecies-platform.patch
    0007-fix-arm-build.patch
    0008-sdl.patch
    0009-glut.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
   FEATURES
     anim         WEBP_BUILD_ANIM_UTILS
     gif2webp     WEBP_BUILD_GIF2WEBP
     img2webp     WEBP_BUILD_IMG2WEBP
     vwebp        WEBP_BUILD_VWEBP
     vwebp-sdl    WEBP_HAVE_SDL
     info         WEBP_BUILD_WEBPINFO
     mux          WEBP_BUILD_WEBPMUX
     extras       WEBP_BUILD_EXTRAS
     nearlossless WEBP_NEAR_LOSSLESS
     simd         WEBP_ENABLE_SIMD
     cwebp        WEBP_BUILD_CWEBP
     dwebp        WEBP_BUILD_DWEBP
     swap16bitcsp WEBP_ENABLE_SWAP_16BIT_CSP
     unicode      WEBP_UNICODE
     libbwebpmux  WEBP_BUILD_LIBWEBPMUX
)


if(VCPKG_TARGET_IS_LINUX)
    message("WebP currently requires the following library from the system package manager:\n    Xxf86vm\n\nThis can be installed on Ubuntu systems via apt-get install libxxf86vm-dev")
endif()

if(VCPKG_TARGET_IS_OSX)
    if("vwebp" IN_LIST FEATURES OR "extras" IN_LIST FEATURES)
        message(FATAL_ERROR "Due to GLUT Framework problems with CMake, at the moment it's not possible to build VWebP or extras on Mac!")
    endif()
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS
    ${FEATURE_OPTIONS}
  OPTIONS_DEBUG
    -DCMAKE_DEBUG_POSTFIX=d
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME WebP CONFIG_PATH share/WebP/cmake) # find_package is called with WebP not libwebp
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

if(NOT DEFINED VCPKG_BUILD_TYPE OR VCPKG_BUILD_TYPE STREQUAL "debug")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libwebp.pc" "-lwebp" "-lwebpd")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libwebpdecoder.pc" "-lwebpdecoder" "-lwebpdecoderd")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libwebpdemux.pc" "-lwebpdemux" "-lwebpdemuxd")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libwebpmux.pc" "-lwebpmux" "-lwebpmuxd")
endif()
vcpkg_fixup_pkgconfig()

set(BIN_NAMES get_disto gif2webp img2webp vwebp vwebp_sdl webpinfo webpmux webp_quality cwebp dwebp)
file(MAKE_DIRECTORY "${CURRENT_PACKAGES_DIR}/tools/webp/")
foreach(tool ${BIN_NAMES})
  if(EXISTS "${CURRENT_PACKAGES_DIR}/debug/bin/${tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    file(REMOVE "${CURRENT_PACKAGES_DIR}/debug/bin/${tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
  endif()

  if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/${tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin/${tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}" "${CURRENT_PACKAGES_DIR}/tools/webp/${tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
  endif()
endforeach()
vcpkg_copy_tool_dependencies("${CURRENT_PACKAGES_DIR}/tools/webp")

#No tools
file(GLOB_RECURSE RESULT "${CURRENT_PACKAGES_DIR}/tools/")
list(LENGTH RESULT RES_LEN)
if(RES_LEN EQUAL 0)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/tools/")
endif()

if(VCPKG_LIBRARY_LINKAGE STREQUAL static)
  file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
