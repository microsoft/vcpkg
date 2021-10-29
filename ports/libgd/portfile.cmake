vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libgd/libgd
    REF 2e40f55bfb460fc9d8cbcd290a0c9eb908d5af7e # gd-2.3.2
    SHA512 c3f2db40f774b44e3fd3fbc743efe70916a71ecd948bf8cb4aeb8a9b9fefd9f17e02d82a9481bac6fcc3624f057b5a308925b4196fb612b65bb7304747d33ffa
    HEAD_REF master
    PATCHES
        0001-fix-cmake.patch
        no-write-source-dir.patch
        intrin.patch
        fix_msvc_build.patch
)

#delete CMake builtins modules
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake/modules/CMakeParseArguments.cmake")
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake/modules/FindFreetype.cmake")
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake/modules/FindJPEG.cmake")
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake/modules/FindPackageHandleStandardArgs.cmake")
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake/modules/FindPNG.cmake")
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake/modules/FindWEBP.cmake")

vcpkg_check_features(
    OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        png          ENABLE_PNG
        jpeg         ENABLE_JPEG
        tiff         ENABLE_TIFF
        freetype     ENABLE_FREETYPE
        webp         ENABLE_WEBP
        fontconfig   ENABLE_FONTCONFIG
)

if(VCPKG_LIBRARY_LINKAGE STREQUAL dynamic)
  set(LIBGD_SHARED_LIBS ON)
  set(LIBGD_STATIC_LIBS OFF)
else()
  set(LIBGD_SHARED_LIBS OFF)
  set(LIBGD_STATIC_LIBS ON)
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBGD_SHARED_LIBS=${LIBGD_SHARED_LIBS}
        -DBUILD_STATIC_LIBS=${LIBGD_STATIC_LIBS}
        -DBUILD_TEST=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
