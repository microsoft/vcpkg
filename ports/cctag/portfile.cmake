# TODO
# 1. change:
#   - HEAD_REF to master
#   - REF and SHA512 to the release version (remember to push to master the develop with release)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO alicevision/cctag
        #    REF fe24ce67624c16e1cc5620e4427abd55f8478e63
#    REF v1.0.0-rc1
    REF 5284b46c87f34c9df4e9ef18e5f815ba62973b45
#    SHA512 c635b4d38ce95be14ba20bc12043c7ab56631166a62db8389774193edfce3a43aecc2033e8b7c3f2232953f81394d322bd9e7a6fcdb7979a77374b8fc725c8d0
#    SHA512 e1faab2ec85b94da9825ebda8cf2ee23fd430ba81961465d7c5c38c82ef6a6278ee624afa9323ef1034a13d5841f0a8cb4f00fe59a1fb0eaeabd929c7390008f
    SHA512 857a06899ae62c02500c9a3d9190da34b4514ab0ab5e0412ed1fb0b16881658248959556cf07ddfc139335c31f6e1e8c3549366c425f8cd316955ec8e0e47244
    HEAD_REF develop
#    HEAD_REF cmake/win/fixesVcpkg
    HEAD_REF dev/c++14
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
    file(MAKE_DIRECTORY ${CURRENT_PACKAGES_DIR}/tools)
    file(RENAME "${CURRENT_PACKAGES_DIR}/bin" ${CURRENT_PACKAGES_DIR}/tools/cctag)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/bin")
#    file(RENAME "${CURRENT_PACKAGES_DIR}/debug/bin" ${CURRENT_PACKAGES_DIR}/tools/cctag/debug)
    vcpkg_copy_tool_dependencies(${CURRENT_PACKAGES_DIR}/tools/cctag)
endif()

file(INSTALL ${SOURCE_PATH}/COPYING.md DESTINATION ${CURRENT_PACKAGES_DIR}/share/cctag RENAME copyright)