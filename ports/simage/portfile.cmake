vcpkg_fail_port_install(ON_TARGET "uwp")

set(SIMAGE_VERSION 1.8.1)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Coin3D/simage
    REF 72bdc2fddb171ab08325ced9c4e04b27bbd2da6c #v1.8.1
    SHA512 8e0d4b246318e9a08d9a17e0550fae4e3902e5d14ff9d7e43569624d1ceb9308c1cbc2401cedc4bff4da8b136fc57fc6b11c6800f1db15914b13186b0d5dc8f1
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
elseif ((VCPKG_TARGET_IS_LINUX OR VCPKG_TARGET_IS_OSX)
         AND ("gdiplus" IN_LIST FEATURES OR "avienc" IN_LIST FEATURES))
    message(FATAL_ERROR "Feature 'avienc' and 'gdiplus' only support Windows.")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
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
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/simage-${SIMAGE_VERSION})

if (NOT VCPKG_TARGET_IS_WINDOWS OR VCPKG_TARGET_IS_MINGW)
    vcpkg_copy_tools(TOOL_NAMES simage-config AUTO_CLEAN)
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
