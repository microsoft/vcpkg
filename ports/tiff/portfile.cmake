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

vcpkg_download_distfile(CVE_2022_0907_diff
    URLS https://gitlab.com/libtiff/libtiff/-/merge_requests/314.diff
    FILENAME libtiff-CVE-2022-0907.diff
    SHA512 72455bb9698e8670b7ffcc1e6c644b9fd4d3aab46ca5940dc8130c796435a838f05555bf85293770c77b73690b137cd6931d59d61d649482b42b7b98afe88f3a
)

vcpkg_download_distfile(CVE_2022_0908_diff
    URLS https://gitlab.com/libtiff/libtiff/-/commit/a95b799f65064e4ba2e2dfc206808f86faf93e85.diff
    FILENAME libtiff-CVE-2022-0908.diff
    SHA512 1f6bb30c00d671665870aea46898390c1545d00d80e17db07b5136f6bfb85fff8d95c2c63493066b9257d871858935497062d992cf978ca5037d8b079bfdeab1
)

vcpkg_download_distfile(CVE_2022_0909_diff
    URLS https://gitlab.com/libtiff/libtiff/-/merge_requests/310.diff
    FILENAME libtiff-CVE-2022-0909.diff
    SHA512 d675ac09a40136bdc808ae75030f199ebcbaf38b2e904b3b26b21d18e39fe89a1c703d5ee6156b337ec9dde29ad311cb6551de984aa87d796c9af0a26d758af3
)

vcpkg_download_distfile(CVE_2022_0924_diff
    URLS https://gitlab.com/libtiff/libtiff/-/merge_requests/311.diff
    FILENAME libtiff-CVE-2022-0924.diff
    SHA512 dcd22b4ef121128aabc8b2aadf4eac16597ee8b211bb06467c93bbccafe47a45917f07a6f4264d43f4c1596eb54d7d0a073987e6899a9f8d057632244cf75c67
)

vcpkg_download_distfile(CVE_2022_22844_diff
    URLS https://gitlab.com/libtiff/libtiff/-/merge_requests/287.diff
    FILENAME libtiff-CVE-2022-22844.diff
    SHA512 2a3bb8ae9191794bff52a4b776a35b244a24e3b2ca963ccfd40166566fae18a2333d7db6c2e2cf17daa9fe61eaca3bd8c36d9807fd1aa0491a041ec22d65c70e
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
    ${CVE_2022_0907_diff}
    ${CVE_2022_0908_diff}
    ${CVE_2022_0909_diff}
    ${CVE_2022_0924_diff}
    ${CVE_2022_22844_diff}
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
