# TODO
# 1. change:
#   - HEAD_REF to master
#   - REF and SHA512 to the release version (remember to push to master the develop with release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alicevision/cctag
    REF v1.0.0-rc3
    SHA512 e67078aa2452f6fcda7f4adea44c51a27dadd6de262653af63b7468c48374479e65124b3321ba525700279f356c73929e4aceaf55250182403389e79f730279a
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