
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Coin3D/simage
    REF "v${VERSION}"
    SHA512 42981f1dc67f17bc6bfc49ecbf035444b79ab467d5ece4310841856f5ec87d2b4352d5a7cb5713fb14ac5a25928f7d657fb74c93acdcd86b8b0dd89f26a5008a
    HEAD_REF master
    PATCHES requies-all-dependencies.patch
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" SIMAGE_BUILD_SHARED_LIBS)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" SIMAGE_USE_STATIC_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" SIMAGE_USE_MSVC_STATIC_RUNTIME)


vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        avienc      SIMAGE_USE_AVIENC
        gdiplus     SIMAGE_USE_GDIPLUS
        oggvorbis   SIMAGE_OGGVORBIS_SUPPORT
        sndfile     SIMAGE_LIBSNDFILE_SUPPORT
        giflib      SIMAGE_GIF_SUPPORT
        jpeg        SIMAGE_JPEG_SUPPORT
        png         SIMAGE_PNG_SUPPORT
        tiff        SIMAGE_TIFF_SUPPORT
        zlib        SIMAGE_ZLIB_SUPPORT
)

# Depends on the platform
if(VCPKG_TARGET_IS_WINDOWS AND "gdiplus" IN_LIST FEATURES)
    message(WARNING "Feature 'gdiplus' will disable feature 'zlib', 'giflib', 'jpeg', 'png' and 'tiff' automaticly.")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        -DSIMAGE_BUILD_SHARED_LIBS:BOOL=${SIMAGE_BUILD_SHARED_LIBS}
        -DSIMAGE_USE_STATIC_LIBS:BOOL=${SIMAGE_USE_STATIC_LIBS}
        -DSIMAGE_USE_MSVC_STATIC_RUNTIME:BOOL=${SIMAGE_USE_MSVC_STATIC_RUNTIME}
        -DSIMAGE_USE_CGIMAGE=OFF
        -DSIMAGE_USE_QIMAGE=OFF
        -DSIMAGE_USE_QT6=OFF
        -DSIMAGE_USE_QT5=OFF
        -DSIMAGE_USE_CPACK=OFF
        -DSIMAGE_LIBJASPER_SUPPORT=OFF
        -DSIMAGE_EPS_SUPPORT=OFF
        -DSIMAGE_MPEG2ENC_SUPPORT=OFF
        -DSIMAGE_PIC_SUPPORT=OFF
        -DSIMAGE_RGB_SUPPORT=OFF
        -DSIMAGE_XWD_SUPPORT=OFF
        -DSIMAGE_TGA_SUPPORT=OFF
        -DSIMAGE_BUILD_MSVC_MP=OFF
        -DSIMAGE_BUILD_EXAMPLES=OFF
        -DSIMAGE_BUILD_TESTS=OFF
        -DSIMAGE_BUILD_DOCUMENTATION=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/simage-${VERSION})

if (NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_MINGW)
    vcpkg_copy_tools(TOOL_NAMES simage-config AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/share/Coin")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
