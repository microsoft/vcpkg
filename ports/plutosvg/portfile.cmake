vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sammycage/plutosvg
    REF "v${VERSION}"
    SHA512 31f989aef2329ac41c19f8c4852f5a1d5c37dc7726192d230ba2a74262bdc6356facf3295b4d8a05f2be79ba313bcc3f01bd52e4024382c9ce09e259a5421440
    HEAD_REF master
    PATCHES
        find-package-plutovg.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        freetype PLUTOSVG_ENABLE_FREETYPE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DPLUTOSVG_BUILD_EXAMPLES=OFF
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/plutosvg)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/plutosvg/plutosvg.h" "defined(PLUTOSVG_BUILD_STATIC)" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
