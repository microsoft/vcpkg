set(LIBTIFF_VERSION 4.3.0)

vcpkg_download_distfile(CVE_2022_0561_diff
    URLS https://gitlab.com/libtiff/libtiff/-/commit/eecb0712f4c3a5b449f70c57988260a667ddbdef.diff
    FILENAME libtiff-CVE-2022-0561.diff
    SHA512 48df4e93202723778fdb6b87bcb7e2e4118546c6deb47e9999b8818e69420ad52a4a7823c68ab74d30657adb2278641971e43db771a1796fda95d2433ad991a0
)

vcpkg_download_distfile(CVE_2022_0562_diff
    URLS https://gitlab.com/libtiff/libtiff/-/commit/561599c99f987dc32ae110370cfdd7df7975586b.diff
    FILENAME libtiff-CVE-2022-0562.diff
    SHA512 4346098e7a2433cf15d02a7baa3d1fa4b648f58845200264ecc0a230035f15da4cf1427c4a4ff73797bc01f105bd9ff705371c2f3867be4f9103b07d4d0edea8
)

vcpkg_download_distfile(CVE_2022_0865_diff
    URLS https://gitlab.com/libtiff/libtiff/-/merge_requests/306.diff
    FILENAME libtiff-CVE-2022-0865.diff
    SHA512 f22e0cee03716e6c6f130606c74acc7033dd61e20276e38e89a0ba485857d05a7bc22e445c52010797b7020febc30d3aca854d8a0c4ed0e2453201de550b4058
)

vcpkg_download_distfile(CVE_2022_0891_diff
    URLS https://gitlab.com/libtiff/libtiff/-/merge_requests/307.diff
    FILENAME libtiff-CVE-2022-0891.diff
    SHA512 6a88a0423057da11121d5297e2f425199341cbc6b299a0f77dd57baddf3f6a022a6dfe1fb97caabfd6e95a40b6c95a0e6b9a80e199054c271ccb257e23671fcf
)

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libtiff/libtiff
    REF v${LIBTIFF_VERSION}
    SHA512 eaa2503dc1805283e0590b06e3e660a793fe849ae8b975b2d69369695d65a40640787c156574faaca856917be799eeb844e60f55555e1f219dd513cef66ea95d
    HEAD_REF master
    PATCHES cmakelists.patch
    fix-pkgconfig.patch
    FindCMath.patch
    ${CVE_2022_0561_diff}
    ${CVE_2022_0562_diff}
    ${CVE_2022_0865_diff}
    ${CVE_2022_0891_diff}
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
        tools   BUILD_TOOLS
        webp    webp
        zip     zlib
        zstd    zstd
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        ${EXTRA_OPTIONS}
        -DBUILD_DOCS=OFF
        -DBUILD_CONTRIB=OFF
        -DBUILD_TESTS=OFF
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
file(INSTALL "${SOURCE_PATH}/COPYRIGHT" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

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
