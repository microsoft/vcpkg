vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO koide3/small_gicp
    REF "v${VERSION}"
    SHA512 28589b57a75ddb11ae3a1355dffc358d682ae49e390d125365d80b0d14f9043a34c566601af5b0ea7cf939173d1c611106b1cee2f6f7f3cdacb2cdc20fa6e4dc
    HEAD_REF master
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        pcl     BUILD_WITH_PCL
        tbb     BUILD_WITH_TBB
        openmp  BUILD_WITH_OPENMP
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(
    PACKAGE_NAME small_gicp
    CONFIG_PATH lib/cmake/small_gicp
)
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
