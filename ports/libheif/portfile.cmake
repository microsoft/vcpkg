vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO  strukturag/libheif
    REF "v${VERSION}"
    SHA512 556cc0e365aacad662d8c20282b68856b51af168659acd0f2662dcb399e5fed9dea9c259f5d5ffcd383f4b4a00a93acbdc06e90b340cc1dd2098e94c30c8a606
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
        aom         VCPKG_LOCK_FIND_PACKAGE_AOM
        gdk-pixbuf  WITH_GDK_PIXBUF
        hevc        WITH_X265
        hevc        VCPKG_LOCK_FIND_PACKAGE_X265
        iso23001-17 WITH_UNCOMPRESSED_CODEC
        iso23001-17 VCPKG_LOCK_FIND_PACKAGE_ZLIB
        jpeg        WITH_JPEG_DECODER
        jpeg        WITH_JPEG_ENCODER
        jpeg        VCPKG_LOCK_FIND_PACKAGE_JPEG
        openjpeg    WITH_OpenJPEG_DECODER
        openjpeg    WITH_OpenJPEG_ENCODER
        openjpeg    VCPKG_LOCK_FIND_PACKAGE_OpenJPEG
        h264        WITH_X264
        openh264    WITH_OpenH264_DECODER
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
        -DWITH_OpenH264_DECODER=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_Brotli=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_Doxygen=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_LIBDE265=ON   # feature candidate
        -DVCPKG_LOCK_FIND_PACKAGE_PNG=OFF
        -DVCPKG_LOCK_FIND_PACKAGE_TIFF=OFF
        ${FEATURE_OPTIONS}
    OPTIONS_RELEASE
        "-DPLUGIN_INSTALL_DIRECTORY=${CURRENT_PACKAGES_DIR}/plugins/libheif"
    OPTIONS_DEBUG
        "-DPLUGIN_INSTALL_DIRECTORY=${CURRENT_PACKAGES_DIR}/debug/plugins/libheif"
    MAYBE_UNUSED_VARIABLES
        VCPKG_LOCK_FIND_PACKAGE_AOM
        VCPKG_LOCK_FIND_PACKAGE_Brotli
        VCPKG_LOCK_FIND_PACKAGE_OpenJPEG
        VCPKG_LOCK_FIND_PACKAGE_X265
        VCPKG_LOCK_FIND_PACKAGE_ZLIB
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH "lib/cmake/libheif")
vcpkg_fixup_pkgconfig()

if (VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libheif/heif_library.h" "!defined(LIBHEIF_STATIC_BUILD)" "1")
else()
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/libheif/heif_library.h" "!defined(LIBHEIF_STATIC_BUILD)" "0")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/lib/libheif" "${CURRENT_PACKAGES_DIR}/debug/lib/libheif")

file(GLOB maybe_plugins "${CURRENT_PACKAGES_DIR}/plugins/libheif/*")
if(maybe_plugins STREQUAL "")
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/plugins" "${CURRENT_PACKAGES_DIR}/debug/plugins")
endif()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/COPYING")
