vcpkg_from_gitlab(
    GITLAB_URL https://gitlab.com
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libtiff/libtiff
    REF "v${VERSION}"
    SHA512 859331284cd28df56c44644a355ecdd8eece19f0d5cd3e693e37c0fe37115091e46943ffbad784e84af1b39a6fd81cd196af2d4fefe86369258f89050dafaa84
    HEAD_REF master
    PATCHES
        FindCMath.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        cxx     cxx
        jpeg    jpeg
        jpeg    CMAKE_REQUIRE_FIND_PACKAGE_JPEG
        lzma    lzma
        lzma    CMAKE_REQUIRE_FIND_PACKAGE_liblzma
        tools   tiff-tools
        webp    webp
        webp    CMAKE_REQUIRE_FIND_PACKAGE_WebP
        zip     zlib
        zip     CMAKE_REQUIRE_FIND_PACKAGE_ZLIB
        zstd    zstd
        zstd    CMAKE_REQUIRE_FIND_PACKAGE_ZSTD
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DCMAKE_FIND_PACKAGE_PREFER_CONFIG=ON
        -Dtiff-docs=OFF
        -Dtiff-contrib=OFF
        -Dtiff-tests=OFF
        -Dlibdeflate=OFF
        -Djbig=OFF # This is disabled by default due to GPL/Proprietary licensing.
        -Djpeg12=OFF
        -Dlerc=OFF
        -DCMAKE_DISABLE_FIND_PACKAGE_OpenGL=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_GLUT=ON
        -DZSTD_HAVE_DECOMPRESS_STREAM=ON
        -DHAVE_JPEGTURBO_DUAL_MODE_8_12=OFF
    OPTIONS_DEBUG
        -DCMAKE_DEBUG_POSTFIX=d # tiff sets "d" for MSVC only.
    MAYBE_UNUSED_VARIABLES
        ZSTD_HAVE_DECOMPRESS_STREAM
)

vcpkg_cmake_install()

# CMake config wasn't packaged in the past and is not yet usable now,
# cf. https://gitlab.com/libtiff/libtiff/-/merge_requests/496
# vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/tiff")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/cmake" "${CURRENT_PACKAGES_DIR}/debug/lib/cmake")

set(_file "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libtiff-4.pc")
if(EXISTS "${_file}")
    vcpkg_replace_string("${_file}" "-ltiff" "-ltiffd")
endif()
vcpkg_fixup_pkgconfig()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

configure_file("${CMAKE_CURRENT_LIST_DIR}/vcpkg-cmake-wrapper.cmake.in" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)

if ("tools" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES
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
        AUTO_CLEAN
    )
endif()

vcpkg_copy_pdbs()
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE.md")
