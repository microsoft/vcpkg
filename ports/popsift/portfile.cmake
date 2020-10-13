# TODO
# 1. change:
#   - HEAD_REF to master
#   - REF and SHA512 to the release version (remember to push to master the develop with release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alicevision/popsift	
    REF v1.0.0-rc2
    SHA512 510912f8085c017ef4d8400f9b64c79d5da2ceb887d57917c3b7f7d56257b9741c94980227cdd1fff1ed761b446315f917f153fa5f9ab667b2af3f0ddac4ab86
    HEAD_REF develop
)

include(${CURRENT_INSTALLED_DIR}/share/vcpkg_find_cuda/vcpkg_find_cuda.cmake)
vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT CUDA_TOOLKIT_ROOT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    apps       PopSift_BUILD_EXAMPLES
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS ${FEATURE_OPTIONS} -DCUDA_TOOLKIT_ROOT=${CUDA_TOOLKIT_ROOT}
)

vcpkg_install_cmake()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/PopSift)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include ${CURRENT_PACKAGES_DIR}/debug/share)

 # move the bin direcory to tools
 if ("apps" IN_LIST FEATURES)
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin" ${CURRENT_PACKAGES_DIR}/tools/popsift)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
#    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin" ${CURRENT_PACKAGES_DIR}/tools/popsift/debug)
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/popsift)
 endif()

file(INSTALL ${SOURCE_PATH}/COPYING.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/popsift RENAME copyright)