vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO libgd/libgd
    REF b5319a41286107b53daa0e08e402aa1819764bdc # gd-2.3.3
    SHA512 b4c6ca1d9575048de35a38b0db69e7380e160293133c1f72ae570f83ce614d4f2fd2615d217f7a0023e2265652c1089561b906beabca56c15e6ec0250e4394b2
    HEAD_REF master
    PATCHES
        0001-fix-cmake.patch
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

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" BUILD_STATIC)
string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" BUILD_SHARED)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBGD_SHARED_LIBS=${BUILD_SHARED}
        -DBUILD_STATIC_LIBS=${BUILD_STATIC}
        -DBUILD_TEST=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/COPYING" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_fixup_pkgconfig()
