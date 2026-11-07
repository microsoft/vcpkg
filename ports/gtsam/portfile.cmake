vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO borglab/gtsam
    REF "${VERSION}"
    SHA512 b745c1d9a677a0980cbc5823851b32980b72e93378c0727be00eba294132542ad2c7f1c502d3c9b3416c8ea25b68609c43355b2f0f4c60ada432f952d7347dca
    HEAD_REF develop
    PATCHES
        build-fixes.patch
        path-fixes.patch
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        boost GTSAM_ENABLE_BOOST_SERIALIZATION
        boost GTSAM_USE_BOOST_FEATURES
        tbb   GTSAM_WITH_TBB
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DCMAKE_DISABLE_FIND_PACKAGE_CHOLMOD=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Doxygen=ON
        -DGTSAM_BUILD_TESTS=OFF
        -DGTSAM_BUILD_EXAMPLES_ALWAYS=OFF
        -DGTSAM_BUILD_TIMING_ALWAYS=OFF
        -DGTSAM_BUILD_UNSTABLE=OFF
        -DGTSAM_UNSTABLE_BUILD_PYTHON=OFF
        -DGTSAM_USE_SYSTEM_EIGEN=ON
        -DGTSAM_USE_SYSTEM_CCOLAMD=OFF
        -DGTSAM_USE_SYSTEM_METIS=ON
        -DGTSAM_INSTALL_CPPUNITLITE=OFF
        -DGTSAM_BUILD_TYPE_POSTFIXES=OFF
        ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_cmake_config_fixup(PACKAGE_NAME GTSAM CONFIG_PATH CMake)
else()
    vcpkg_cmake_config_fixup(PACKAGE_NAME GTSAM CONFIG_PATH lib/cmake/GTSAM)
endif()
vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

vcpkg_install_copyright(
    FILE_LIST
        "${SOURCE_PATH}/LICENSE"
        "${SOURCE_PATH}/LICENSE.BSD"
        "${SOURCE_PATH}/gtsam/3rdparty/CCOLAMD/Doc/License.txt"
        "${SOURCE_PATH}/gtsam/3rdparty/SuiteSparse_config/README.txt"
        "${SOURCE_PATH}/gtsam/3rdparty/cephes/LICENSE.txt"
)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
