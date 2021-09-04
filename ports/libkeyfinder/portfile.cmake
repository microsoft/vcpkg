vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO mixxxdj/libkeyfinder
    REF v2.2.5
    SHA512 54463d1f1111dc474d3e43723fddd5579ea1a3842f99f43e50e85622a1d6ee6fe42b22c300ce5ba5807cf6b2d7067af741773af95974a42c5d863c53165893eb
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
      test BUILD_TESTING
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME KeyFinder CONFIG_PATH lib/cmake/KeyFinder)

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
