vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO Maratyszcza/nnpack
    REF c07e3a0400713d546e0dea2d5466dd22ea389c73
    SHA512 f0b261e8698b412d12dd739e5d0cf71c284965ae28da735ae22814a004358ba3ecaea6cd26fa17b594c0245966b7dd2561c1e05c6cbf0592fd7b85ea0f21eb37
    PATCHES
        fix-cmakelists.patch
)

vcpkg_cmake_configure(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DNNPACK_BACKEND=psimd
        -DNNPACK_BUILD_TESTS=OFF
        -DNNPACK_BUILD_BENCHMARKS=OFF
        -DNNPACK_CUSTOM_THREADPOOL=OFF
    MAYBE_UNUSED_VARIABLES
        NNPACK_BUILD_BENCHMARKS

)
vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup(PACKAGE_NAME unofficial-${PORT})
file(INSTALL ${SOURCE_PATH}/LICENSE DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT} RENAME copyright)
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)
