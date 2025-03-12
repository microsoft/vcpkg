vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alicevision/popsift
    REF v0.9
    SHA512 56789520872203eea86e07e8210e00c0b67d85486af16df9d620b1aff10f8d9ef5d910cf1dda6c68af7ca2ed11658ab5414ac79117b543f91a7d8d6a96a17ce0
    HEAD_REF develop
    PATCHES
        fix_missing_thrust_include.patch
        144.patch
        cuda_12_1.patch
)

vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT CUDA_TOOLKIT_ROOT)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        apps       PopSift_BUILD_EXAMPLES
)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
        "-DCUDA_TOOLKIT_ROOT_DIR=${CUDA_TOOLKIT_ROOT}"
        #"-DPopSift_USE_NVTX_PROFILING=ON" # won't compile otherwise with newer CUDA
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/PopSift)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include" "${CURRENT_PACKAGES_DIR}/debug/share")

# copy the apps in tools directory
if ("apps" IN_LIST FEATURES)
    vcpkg_copy_tools(TOOL_NAMES popsift-demo AUTO_CLEAN)
endif()

file(INSTALL "${SOURCE_PATH}/COPYING.md" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}" RENAME copyright)
