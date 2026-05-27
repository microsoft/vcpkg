vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO borglab/gtsam
    REF ${VERSION}
    SHA512 49de9c77c0e1b0297123eefcadd31841c1c0e01c9eed0a0ded099e728f9bd07e66512e6e0b6ed73bd8aa8e4fc3b8bb6aad6586d1bca8b4936d821af482719f7b
    HEAD_REF develop
    PATCHES
        build-fixes.patch
        path-fixes.patch
        eigen3-fixes.patch
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
