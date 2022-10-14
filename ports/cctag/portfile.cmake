vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alicevision/cctag
    REF v1.0.2
    SHA512 ccd62f6b1ca55035a08660052f38e73866260d5295490864fa9c86af779a42ce2ec727d6c88f0ea38f205903cf8f4107069b690849e432219c74d3b9666e3ae2
    HEAD_REF develop
    PATCHES
        0001-fix-osx.patch
        0002-find-tbb.patch # Includes changes similar to https://github.com/alicevision/CCTag/pull/178/
)

file(REMOVE "${SOURCE_PATH}/cmake/FindTBB.cmake" "${SOURCE_PATH}/src/applications/cmake/FindTBB.cmake")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
        FEATURES
            cuda       CCTAG_WITH_CUDA
            apps       CCTAG_BUILD_APPS
)

if("cuda" IN_LIST FEATURES)
    include("${CURRENT_INSTALLED_DIR}/share/cuda/vcpkg_find_cuda.cmake")
    vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT CUDA_TOOLKIT_ROOT)
    message(STATUS "CUDA_TOOLKIT_ROOT ${CUDA_TOOLKIT_ROOT}")
endif()

vcpkg_cmake_configure(
    SOURCE_PATH  "${SOURCE_PATH}"
    OPTIONS -DCCTAG_BUILD_TESTS:BOOL=OFF ${FEATURE_OPTIONS}
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/CCTag)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

# remove test files
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/cctag/geometry/test" "${CURRENT_PACKAGES_DIR}/include/cctag/test")
# remove cuda headers
if(NOT "cuda" IN_LIST FEATURES)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/cctag/cuda")
endif()

 # move the bin directory to tools
if ("apps" IN_LIST FEATURES)
    set(CCTAG_TOOLS detection regression simulation)
    vcpkg_copy_tools(TOOL_NAMES ${CCTAG_TOOLS} AUTO_CLEAN)
endif()

file(INSTALL "${SOURCE_PATH}/COPYING.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
