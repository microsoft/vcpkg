vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  strukturag/libheif
    REF "v${VERSION}"
    SHA512 74bc51caf30997e1d327ab8253e9d3556906cd14828794a72c4ba42f2c154b79c1d717e0833a6afc3f6ebff909b630326c11a052d7eb832008769157fad3760b
    HEAD_REF master
    PATCHES
        gdk-pixbuf.patch
        support-uncompress.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        hevc        WITH_X265
        aom         WITH_AOM_DECODER
        aom         WITH_AOM_ENCODER
        openjpeg    WITH_OpenJPEG_DECODER
        openjpeg    WITH_OpenJPEG_ENCODER
        jpeg        WITH_JPEG_DECODER
        jpeg        WITH_JPEG_ENCODER
        iso23001-17 WITH_UNCOMPRESSED_CODEC
        gdk-pixbuf  WITH_GDKPIXBUF2
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DWITH_EXAMPLES=OFF
        -DWITH_DAV1D=OFF
        -DBUILD_TESTING=OFF
        -DCMAKE_COMPILE_WARNING_AS_ERROR=OFF
        ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/libheif/)
# libheif's pc file assumes libstdc++, which isn't always true.
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libheif.pc" " -lstdc++" "" IGNORE_UNCHANGED)
if(NOT VCPKG_BUILD_TYPE)
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libheif.pc" " -lstdc++" "" IGNORE_UNCHANGED)
endif()
vcpkg_fixup_pkgconfig()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libheif/heif_library.h" "!defined(LIBHEIF_STATIC_BUILD)" "1")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libheif/heif_library.h" "!defined(LIBHEIF_STATIC_BUILD)" "0")
endif()
vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libheif/heif_library.h" "#ifdef LIBHEIF_EXPORTS" "#if 0")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/libheif" "${CURRENT_PACKAGES_DIR}/debug/lib/libheif")

vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libheif/heif_version.h" "#define LIBHEIF_PLUGIN_DIRECTORY \"${CURRENT_PACKAGES_DIR}/lib/libheif\"" "")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
