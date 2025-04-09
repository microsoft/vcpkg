if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO configcat/cpp-sdk
    REF "v${VERSION}"
    SHA512 498fa7ec01f287cdf74cc9aba552259595e300cb038f3d2d6b46d298b009eab7a06d949fbd1640f88da7d40ec6335fea538b3aa43bad6dbf76eced203baac782
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    INVERTED_FEATURES
        network CONFIGCAT_USE_EXTERNAL_NETWORK_ADAPTER
        sha     CONFIGCAT_USE_EXTERNAL_SHA
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCONFIGCAT_BUILD_TESTS=OFF
        ${FEATURE_OPTIONS}
)
vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH "share/cmake/configcat")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
