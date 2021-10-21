set(LIBTIFF_VERSION 4.3.0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.osgeo.org/libtiff/tiff-${LIBTIFF_VERSION}.tar.gz"
    FILENAME "tiff-${LIBTIFF_VERSION}.tar.gz"
    SHA512 e04a4a6c542e58a174c1e9516af3908acf1d3d3e1096648c5514f4963f73e7af27387a76b0fbabe43cf867a18874088f963796a7cd6e45deb998692e3e235493
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE "${ARCHIVE}"
    REF ${LIBTIFF_VERSION}
    PATCHES
        cmakelists.patch
        fix-pkgconfig.patch
        FindCMath.patch
)

set(EXTRA_OPTIONS "")
if(VCPKG_TARGET_IS_UWP)
    list(APPEND EXTRA_OPTIONS "-DUSE_WIN32_FILEIO=OFF")  # On UWP we use the unix I/O api.
endif()

if("cxx" IN_LIST FEATURES)
    vcpkg_fail_port_install(
        MESSAGE "Feature 'cxx' is not supported on ${VCPKG_TARGET_ARCHITECTURE}."
        ON_ARCH arm arm64
    )
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
        -DCMAKE_DEBUG_POSTFIX=d # tiff sets "d" for MSVC only.
        -Dlibdeflate=OFF
        -Djbig=OFF # This is disabled by default due to GPL/Proprietary licensing.
        -Djpeg12=OFF
        -Dlerc=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenGL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_GLUT=ON
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
