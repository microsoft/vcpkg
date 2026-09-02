vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  strukturag/libheif
    REF "v${VERSION}"
    SHA512 b8c153f9efb2a06f77b3de50377d492dc19a6f6f61fc8073fb4b50f7b8375a4cfb634e48390010aab868185c14d5e99a7bbd3c4cf7b3eb41827641107c8778c2
    HEAD_REF master
    PATCHES
        cxx-linkage-pkgconfig.diff
        find-modules.diff
        gdk-pixbuf.patch
        symbol-exports.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        aom         WITH_AOM_DECODER
        aom         WITH_AOM_ENCODER
        gdk-pixbuf  WITH_GDK_PIXBUF
        hevc        WITH_X265
        iso23001-17 WITH_UNCOMPRESSED_CODEC
        header-compression WITH_HEADER_COMPRESSION
        jpeg        WITH_JPEG_DECODER
        jpeg        WITH_JPEG_ENCODER
        openjpeg    WITH_OpenJPEG_DECODER
        openjpeg    WITH_OpenJPEG_ENCODER
        uvg266      WITH_UVG266
        x264        WITH_X264
        h264-decoder WITH_OpenH264_DECODER
)

vcpkg_find_acquire_program(PKGCONFIG)
set(ENV{PKG_CONFIG} "${PKGCONFIG}")

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DBUILD_TESTING=OFF
        -DCMAKE_COMPILE_WARNING_AS_ERROR=OFF
        "-DCMAKE_PROJECT_INCLUDE=${CURRENT_PORT_DIR}/cmake-project-include.cmake"
        -DPLUGIN_DIRECTORY=  # empty
        -DWITH_DAV1D=OFF
        -DWITH_EXAMPLES=OFF
        -DWITH_LIBSHARPYUV=OFF
        ${FEATURE_OPTIONS}
    OPTIONS_RELEASE
        "-DPLUGIN_INSTALL_DIRECTORY=${CURRENT_PACKAGES_DIR}/plugins/libheif"
    OPTIONS_DEBUG
        "-DPLUGIN_INSTALL_DIRECTORY=${CURRENT_PACKAGES_DIR}/debug/plugins/libheif"
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/libheif")
vcpkg_fixup_pkgconfig()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libheif/heif_export.h" "!defined(LIBHEIF_STATIC_BUILD)" "1")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libheif/heif_export.h" "!defined(LIBHEIF_STATIC_BUILD)" "0")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/libheif" "${CURRENT_PACKAGES_DIR}/debug/lib/libheif")

file(GLOB maybe_plugins "${CURRENT_PACKAGES_DIR}/plugins/libheif/*")
if(maybe_plugins STREQUAL "")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/plugins" "${CURRENT_PACKAGES_DIR}/debug/plugins")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
