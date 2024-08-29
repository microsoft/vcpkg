vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO koide3/small_gicp
    REF "v${VERSION}"
    SHA512 b4d4b662d74b5492b7b89bcaf022e2d90262eecd3f1b6d3229edefbb00288a95910d486e66a9e884528f6f9c253a5e535ce7f96829fdc760f58ac001f6192790
    HEAD_REF master
    PATCHES preprocessor_portability.patch
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
