vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alicevision/cctag
    REF v1.0.0
    SHA512 49028356215dd703727b2eedd6aa72d81af84e5ca36f8dc7e9caf85a85c7f500b3eeaaa7369314a40049a72593d70049b709b453c30ff352d98ab0dea3afef76
    HEAD_REF develop
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
        FEATURES
            cuda       CCTAG_WITH_CUDA
            apps       CCTAG_BUILD_APPS
)

if("cuda" IN_LIST FEATURES)
    include(${CURRENT_INSTALLED_DIR}/share/vcpkg_find_cuda/vcpkg_find_cuda.cmake)
    vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT CUDA_TOOLKIT_ROOT)

    message(STATUS "CUDA_TOOLKIT_ROOT ${CUDA_TOOLKIT_ROOT}")
endif()

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS -DCCTAG_BUILD_TESTS:BOOL=OFF ${FEATURE_OPTIONS}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/CCTag)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

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

file(INSTALL ${SOURCE_PATH}/COPYING.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/cctag RENAME copyright)