vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libtiff/libtiff
    REF "v${VERSION}rc1"
    SHA512 c9677d11c1588b9af669abb2642c9edcba0394a3e48de345bbb2a19bcadee4de39884895db1b39a2d4172b046139801a5cd6144d60b204fbd89f0e6a7f8f5b96
    HEAD_REF master
    PATCHES
        FindCMath.patch
)

set(EXTRA_OPTIONS "")
if(VCPKG_TARGET_IS_UWP)
    list(APPEND EXTRA_OPTIONS "-DUSE_WIN32_FILEIO=OFF")  # On UWP we use the unix I/O api.
endif()

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cxx     cxx
        jpeg    jpeg
        lzma    lzma
        tools   tiff-tools
        webp    webp
        zip     zlib
        zstd    zstd
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${EXTRA_OPTIONS}
        -Dtiff-docs=OFF
        -Dtiff-contrib=OFF
        -Dtiff-tests=OFF
        -Dlibdeflate=OFF
        -Djbig=OFF # This is disabled by default due to GPL/Proprietary licensing.
        -Djpeg12=OFF
        -Dlerc=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenGL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_GLUT=ON
    OPTIONS_DEBUG
        -DCMAKE_DEBUG_POSTFIX=d # tiff sets "d" for MSVC only.
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/${PORT}")

set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libtiff-4.pc")
if(EXISTS "${_file}")
    vcpkg_replace_string("${_file}" "-ltiff" "-ltiffd")
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
    "${CURRENT_PACKAGES_DIR}/share"
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)

if ("tools" IN_LIST FEATURES)
    set(_tools
        fax2ps
        fax2tiff
        pal2rgb
        ppm2tiff
        raw2tiff
        tiff2bw
        tiff2pdf
        tiff2ps
        tiff2rgba
        tiffcmp
        tiffcp
        tiffcrop
        tiffdither
        tiffdump
        tiffinfo
        tiffmedian
        tiffset
        tiffsplit
    )
    vcpkg_copy_tools(TOOL_NAMES ${_tools} AUTO_CLEAN)
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
