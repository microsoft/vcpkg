vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sammycage/plutosvg
    REF "v${VERSION}"
    SHA512 efb9e315e7a244d2e790cca0a87c9739570c20b0ace38f703330df402f06f2bad05ebbad4c62382601d9b6ac035f8d5111848a10cf4683ddbab6b315cd864820
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        freetype    PLUTOSVG_ENABLE_FREETYPE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DPLUTOSVG_BUILD_EXAMPLES=OFF
        -DCMAKE_REQUIRE_FIND_PACKAGE_plutovg=1
)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/plutosvg)
vcpkg_fixup_pkgconfig()

if(VCPKG_LIBRARY_LINKAGE STREQUAL "static")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/plutosvg/plutosvg.h" "defined(PLUTOSVG_BUILD_STATIC)" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
