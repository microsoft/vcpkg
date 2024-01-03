if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO jbaldwin/libcoro
    REF "v${VERSION}"
    SHA512 88d5954591493ad2942fa68ead65b67fa9ac26bcc260b3156844244968dd8477d62a3559a9d3b7b1175bf813e5f23ca2d288a72baeb3ebd774e756d3c06bfee8
    HEAD_REF master
    PATCHES
        0001-allow-shared-lib.patch
        0002-disable-git-config.patch
        0003-fix-pkgconfig-includedir.patch
        0004-fix-pkgconfig-on-windows.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        networking   LIBCORO_FEATURE_NETWORKING
        platform     LIBCORO_FEATURE_PLATFORM
        ssl          LIBCORO_FEATURE_SSL
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DLIBCORO_EXTERNAL_DEPENDENCIES=ON
        -DLIBCORO_BUILD_TESTS=OFF
        -DLIBCORO_BUILD_EXAMPLES=OFF
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")

vcpkg_fixup_pkgconfig()
