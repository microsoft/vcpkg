vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO borglab/gtsam
    REF ${VERSION}
    SHA512 c0e5de8d86ea8241b49449bd291999ec0d6530bc9943b213e7c650b0ab29894ab53636bd1a0ed82d9d9d148dfc399ebff28e108b060d2d2176b584823bd722cd
    HEAD_REF develop    
    PATCHES
        build-fixes.patch
        path-fixes.patch
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
