vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO borglab/gtsam
    REF "${VERSION}"
    SHA512 63f77fb725c3466f548425e9f7c2459268034bbbdaca9d091265171da0b23078dbce6ff031d2b97b61e0eb8955b70b271119924754c8ed27bba62b33613cc46b
    HEAD_REF develop
    PATCHES
        build-fixes.patch
        path-fixes.patch
        eigen3-fixes.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        tbb   GTSAM_WITH_TBB
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGTSAM_BUILD_TESTS=OFF
        -DGTSAM_BUILD_EXAMPLES_ALWAYS=OFF
        -DGTSAM_BUILD_TIMING_ALWAYS=OFF
        -DGTSAM_BUILD_UNSTABLE=OFF
        -DGTSAM_UNSTABLE_BUILD_PYTHON=OFF
        -DGTSAM_USE_SYSTEM_EIGEN=ON
        -DGTSAM_USE_SYSTEM_METIS=ON
        -DGTSAM_INSTALL_CPPUNITLITE=OFF
        -DGTSAM_BUILD_TYPE_POSTFIXES=OFF
        -DCMAKE_CXX_STANDARD=14 # Boost-math require C++14
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(PACKAGE_NAME GTSAM CONFIG_PATH CMake)
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME GTSAM CONFIG_PATH lib/cmake/GTSAM)
endif()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${SOURCE_PATH}/LICENSE.BSD")
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
