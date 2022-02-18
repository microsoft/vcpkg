vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Maratyszcza/nnpack
    REF c07e3a0400713d546e0dea2d5466dd22ea389c73
    SHA512 f0b261e8698b412d12dd739e5d0cf71c284965ae28da735ae22814a004358ba3ecaea6cd26fa17b594c0245966b7dd2561c1e05c6cbf0592fd7b85ea0f21eb37
    PATCHES
        fix-cmakelists.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DNNPACK_BACKEND=psimd
        -DNNPACK_BUILD_TESTS=OFF
        -DNNPACK_BUILD_BENCHMARKS=OFF
        -DNNPACK_CUSTOM_THREADPOOL=OFF
)
vcpkg_install_cmake()
vcpkg_copy_pdbs()

file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
