vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO webmproject/libwebp
    REF v1.2.4
    SHA512 85c7d2bd1697ed6f18d565056d0105edd63697f144d2c935e9c0563ff09f4acc56d4ac509668f920e8d5dc3c74b53a42f65265fc758fed173cb2168c4d6a551c
    HEAD_REF master
    PATCHES
        0002-cmake-config.patch
        0003-fix-tool-dependencies.patch
        0007-fix-arm-build.patch
        0008-sdl.patch
        0009-glut.patch
        0010-fix_build.patch
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
        libwebpmux   WEBP_BUILD_LIBWEBPMUX
)

if(VCPKG_TARGET_IS_OSX)
    if("vwebp" IN_LIST FEATURES OR "extras" IN_LIST FEATURES)
        message(FATAL_ERROR "Due to GLUT Framework problems with CMake, at the moment it's not possible to build VWebP or extras on Mac!")
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME WebP CONFIG_PATH share/WebP/cmake)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

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

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)