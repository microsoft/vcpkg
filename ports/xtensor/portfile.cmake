# header-only library

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO xtensor-stack/xtensor
    REF "${VERSION}"
    SHA512 1b2683225a400e2ed06679eedc13c001be80163afb8b42918091670995c04f26ef03ffa9ef72ec7fe6c9d4c1aa88df9ad17698abe5ccd8b19a057ebc10956594
    HEAD_REF master
    PATCHES
        fix-find-tbb-and-install-destination.patch
        fix-find-xsimd.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        xsimd XTENSOR_USE_XSIMD
        tbb XTENSOR_USE_TBB
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DXTENSOR_ENABLE_ASSERT=OFF
        -DXTENSOR_CHECK_DIMENSION=OFF
        -DBUILD_TESTS=OFF
        -DBUILD_BENCHMARK=OFF
        -DDOWNLOAD_GTEST=OFF
        -DDOWNLOAD_GBENCHMARK=OFF
        -DDEFAULT_COLUMN_MAJOR=OFF
        -DDISABLE_VS2017=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug" "${CURRENT_PACKAGES_DIR}/lib")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
