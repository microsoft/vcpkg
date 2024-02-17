vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/highway
    REF "${VERSION}"
    SHA512 6ee5007ec13ac20b5d816b38a1b31c31a06678ca6d2ea090dd75e364f04cb2cf7ad8a82d1bdfff51079efa54b9a95fb554d62e6cc1bbf7d7e794cb272032d8f5
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        contrib  HWY_ENABLE_CONTRIB
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DHWY_ENABLE_INSTALL=ON
        -DHWY_ENABLE_EXAMPLES=OFF
        -DHWY_ENABLE_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME hwy CONFIG_PATH lib/cmake/hwy)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/hwy/highway_export.h" "defined(HWY_SHARED_DEFINE)" "1")
endif()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
vcpkg_fixup_pkgconfig()

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
