vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vpetrigo/smf
    REF v0.1.0
    SHA512 fe52cb5c064312568480184eac0f6076600cd0933624e0e4328e6f8d2d661fde61ae8018f5ac37b50da044311d9c135baf54bc143ff047f288cc37b1f947f56b
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        hierarchical    SMF_ANCESTOR_SUPPORT
)

vcpkg_cmake_configure(SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        "${FEATURE_OPTIONS}"
)
vcpkg_cmake_install()
file(INSTALL "${SOURCE_PATH}/LICENSE.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/smf)
file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
