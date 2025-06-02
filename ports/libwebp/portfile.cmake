vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO webmproject/libwebp
    REF "v${VERSION}"
    SHA512 a922cb84e147f1aeaaac9ff4c6000ebad067a9a4b74d94c25d6c9181f487dfd6d8c7966ac1d239f4fad65cc07ad3d5c82ee9ab4adfa4b125d231056781632548
    HEAD_REF master
    PATCHES
        0002-cmake-config.patch
        0003-simd.patch
        0008-sdl.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        anim         WEBP_BUILD_ANIM_UTILS
        cwebp        WEBP_BUILD_CWEBP
        dwebp        WEBP_BUILD_DWEBP
        extras       WEBP_BUILD_EXTRAS
        gif2webp     WEBP_BUILD_GIF2WEBP
        img2webp     WEBP_BUILD_IMG2WEBP
        info         WEBP_BUILD_WEBPINFO
        libwebpmux   WEBP_BUILD_LIBWEBPMUX
        mux          WEBP_BUILD_WEBPMUX
        nearlossless WEBP_NEAR_LOSSLESS
        simd         WEBP_ENABLE_SIMD
        swap16bitcsp WEBP_ENABLE_SWAP_16BIT_CSP
        unicode      WEBP_UNICODE
        vwebp        WEBP_BUILD_VWEBP
        vwebp-sdl    CMAKE_REQUIRE_FIND_PACKAGE_SDL
    INVERTED_FEATURES
        vwebp-sdl    CMAKE_DISABLE_FIND_PACKAGE_SDL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
    OPTIONS_DEBUG
        -DWEBP_BUILD_ANIM_UTILS=OFF
        -DWEBP_BUILD_CWEBP=OFF
        -DWEBP_BUILD_DWEBP=OFF
        -DWEBP_BUILD_EXTRAS=OFF
        -DWEBP_BUILD_GIF2WEBP=OFF
        -DWEBP_BUILD_IMG2WEBP=OFF
        -DWEBP_BUILD_VWEBP=OFF
        -DWEBP_BUILD_WEBPINFO=OFF
        -DWEBP_BUILD_WEBPMUX=OFF
    MAYBE_UNUSED_VARIABLES
        CMAKE_DISABLE_FIND_PACKAGE_SDL
        CMAKE_REQUIRE_FIND_PACKAGE_SDL
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME WebP CONFIG_PATH share/WebP/cmake)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_fixup_pkgconfig()

vcpkg_list(SET BIN_NAMES)
foreach(tool IN ITEMS get_disto gif2webp img2webp vwebp vwebp_sdl webpinfo webpmux webp_quality cwebp dwebp)
    if(EXISTS "${CURRENT_PACKAGES_DIR}/bin/${tool}${VCPKG_TARGET_EXECUTABLE_SUFFIX}")
        vcpkg_list(APPEND BIN_NAMES "${tool}")
    endif()
endforeach()
if(NOT BIN_NAMES STREQUAL "")
    vcpkg_copy_tools(TOOL_NAMES ${BIN_NAMES} AUTO_CLEAN)
endif()

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST ${SOURCE_PATH}/COPYING ${SOURCE_PATH}/PATENTS)
