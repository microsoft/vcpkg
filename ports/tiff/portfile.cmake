set(LIBTIFF_VERSION 4.3.0)

vcpkg_download_distfile(ARCHIVE
    URLS "https://download.osgeo.org/libtiff/tiff-${LIBTIFF_VERSION}.tar.gz"
    FILENAME "tiff-${LIBTIFF_VERSION}.tar.gz"
    SHA512 e04a4a6c542e58a174c1e9516af3908acf1d3d3e1096648c5514f4963f73e7af27387a76b0fbabe43cf867a18874088f963796a7cd6e45deb998692e3e235493
)

vcpkg_extract_source_archive_ex(
    OUT_SOURCE_PATH SOURCE_PATH
    ARCHIVE ${ARCHIVE}
    REF ${LIBTIFF_VERSION}
    PATCHES
        cmakelists.patch
)

set(EXTRA_OPTIONS "")
if(VCPKG_TARGET_IS_UWP)
    list(APPEND EXTRA_OPTIONS "-DUSE_WIN32_FILEIO=OFF")  # On UWP we use the unix I/O api.
endif()

if(VCPKG_TARGET_ARCHITECTURE STREQUAL "arm64" OR VCPKG_TARGET_ARCHITECTURE STREQUAL "arm")
    list(APPEND EXTRA_OPTIONS "-Dcxx=OFF")
endif()


vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tool    BUILD_TOOLS
        zstd    zstd
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        ${FEATURE_OPTIONS}
        ${EXTRA_OPTIONS}
        -DBUILD_DOCS=OFF
        -DBUILD_CONTRIB=OFF
        -DBUILD_TESTS=OFF
        -DCMAKE_DEBUG_POSTFIX=d # tiff sets "d" for MSVC only.
        -DVERSION=${LIBTIFF_VERSION} # Needed for pc file
        -Djbig=OFF # This is disabled by default due to GPL/Proprietary licensing.
        -Djpeg12=OFF
        -Dwebp=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenGL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_GLUT=ON
)

vcpkg_install_cmake()
set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libtiff-4.pc")
if(EXISTS "${_file}")
    vcpkg_replace_string("${_file}" "-ltiff" "-ltiffd")
endif()

# Fix dependencies:
set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libtiff-4.pc")
if(EXISTS "${_file}")
    vcpkg_replace_string("${_file}" "Version: ${LIBTIFF_VERSION}" "Version: ${LIBTIFF_VERSION}\nRequires.private: liblzma libjpeg")
endif() 
set(_file "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libtiff-4.pc")
if(EXISTS "${_file}")
    vcpkg_replace_string("${_file}" "Version: ${LIBTIFF_VERSION}" "Version: ${LIBTIFF_VERSION}\nRequires.private: liblzma libjpeg")
endif()

vcpkg_fixup_pkgconfig()
file(REMOVE_RECURSE
    ${CURRENT_PACKAGES_DIR}/debug/include
    ${CURRENT_PACKAGES_DIR}/debug/share
    ${CURRENT_PACKAGES_DIR}/share
)


file(COPY ${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
file(INSTALL ${SOURCE_PATH}/COPYRIGHT DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)

if ("tool" IN_LIST FEATURES)
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
    file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/bin ${CURRENT_PACKAGES_DIR}/debug/bin)
endif()

vcpkg_copy_pdbs()
