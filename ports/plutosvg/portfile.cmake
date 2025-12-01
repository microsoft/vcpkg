vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO sammycage/plutosvg
    REF "v${VERSION}"
    SHA512 978f33f79b31ee4d38fe3caf7c967db44475d370a35ae29c8763201109da1285d42e6837c4638567eb45abeab2e5a97559fd244599ae13b548c4a8956e17dbc5
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
