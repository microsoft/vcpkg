vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO vreitenbach/MeasFlow
    REF "v${VERSION}"
    SHA512 5bf761451cf1996feb3d72dafcdc48557342cecccd4b0ddeddd98ea23be91d148fd981284ae733bcb6c4ed78baf8ec3dee5fc12ccf9ac0a4c99e8713a98f619d
    HEAD_REF main
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        lz4   CMAKE_REQUIRE_FIND_PACKAGE_lz4
        zstd  CMAKE_REQUIRE_FIND_PACKAGE_zstd
    INVERTED_FEATURES
        lz4   CMAKE_DISABLE_FIND_PACKAGE_lz4
        zstd  CMAKE_DISABLE_FIND_PACKAGE_zstd
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}/c"
    OPTIONS
        -DMEAS_BUILD_TESTS=OFF
        -DMEAS_BUILD_QUICKSTART=OFF
        -DMEAS_BUILD_BENCHMARKS=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(PACKAGE_NAME measflow CONFIG_PATH lib/cmake/measflow)
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
