vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO borglab/gtsam
    REF ${VERSION}
    SHA512 0aae0b785a3f7ae25008d0938848e93519786521cca9cd0cd1a8937ec5ac46f3b1ca1bfaaff1ca5812c92f8ef55b729a06c57632da5dd8fc38afc22d3047f8e0
    HEAD_REF master    
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
        -DGTSAM_USE_SYSTEM_EIGEN=On
        -DGTSAM_USE_SYSTEM_METIS=On
        -DGTSAM_INSTALL_CPPUNITLITE=OFF
        -DGTSAM_BUILD_TYPE_POSTFIXES=OFF
        -DCMAKE_CXX_STANDARD=11 # Boost v1.84.0 libraries require C++11
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
