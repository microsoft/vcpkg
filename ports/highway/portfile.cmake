vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO google/highway
    REF "${VERSION}"
    SHA512 75aaa0a3f97c6b044acb146ac4db20c1d813c4215b9c1620e72352d00c136939db7059f599122d6600e385bffa8b24d7fd9c1fe09772f4941e5300767a8c68dd
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
        -DHWY_ENABLE_EXAMPLES=OFF
        -DHWY_ENABLE_TESTS=OFF
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/hwy)

if(VCPKG_LIBRARY_LINKAGE STREQUAL "dynamic")
    vcpkg_replace_string("${CURRENT_PACKAGES_DIR}/include/hwy/highway_export.h" "defined(HWY_SHARED_DEFINE)" "1")
endif()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    # remove test-related pkg-config files that break vcpkg_fixup_pkgconfig
    "${CURRENT_PACKAGES_DIR}/lib/pkgconfig/libhwy-test.pc"
    "${CURRENT_PACKAGES_DIR}/debug/lib/pkgconfig/libhwy-test.pc"
)
vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
