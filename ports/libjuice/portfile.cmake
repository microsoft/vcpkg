vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO paullouisageneau/libjuice
    REF e7218e30fef3cd4437355aca817fa0980863973a #v1.0.2
    SHA512 b54c827774509915e98faec9891b5121ff50c01c33081480b805ca2f0910f26446cb75d7f721a0b8dfcc87ea7988c7020793befd2788ed132c0f608d434c7eca
    HEAD_REF master
    PATCHES
        fix-for-vcpkg.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        nettle USE_NETTLE
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DNO_TESTS=ON
)

vcpkg_cmake_install()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_cmake_config_fixup(PACKAGE_NAME LibJuice CONFIG_PATH lib/cmake/LibJuice)
vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)