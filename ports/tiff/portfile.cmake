vcpkg_minimum_required(VERSION 2022-10-12) # for ${VERSION}

set(tiff_debian_archive_name "tiff_4.4.0-6.debian.tar.xz")
vcpkg_download_distfile(
    tiff_debian_archive
    URLS "https://deb.debian.org/debian/pool/main/t/tiff/${tiff_debian_archive_name}"
         "https://snapshot.debian.org/archive/debian/20221124T210835Z/pool/main/t/tiff/${tiff_debian_archive_name}"
    FILENAME "${tiff_debian_archive_name}"
    SHA512 a806debc92e8dac573f1e603a91eabb8fa1ab493404d0be62ca926e35f97df2d4514c58bdb93317a91d7f98abb18e9ff91ad51ff0f796a4f94f8b90195c4fdcf
)
vcpkg_extract_source_archive(tiff_debian
    ARCHIVE "${tiff_debian_archive}"
    SOURCE_BASE "debian"
)
file(STRINGS "${tiff_debian}/patches/series" cve_patches REGEX "^CVE-")
list(TRANSFORM cve_patches PREPEND "${tiff_debian}/patches/")

vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libtiff/libtiff
    REF "v${VERSION}"
    SHA512 93955a2b802cf243e41d49048499da73862b5d3ffc005e3eddf0bf948a8bd1537f7c9e7f112e72d082549b4c49e256b9da9a3b6d8039ad8fc5c09a941b7e75d7
    HEAD_REF master
    PATCHES
        cmakelists.patch
        FindCMath.patch
        android-libm.patch
        ${cve_patches}
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
    set(tools
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
    vcpkg_copy_tools(TOOL_NAMES ${tools} AUTO_CLEAN)
elseif(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()

vcpkg_copy_pdbs()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYRIGHT")
