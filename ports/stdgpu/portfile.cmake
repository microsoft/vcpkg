# stdgpu's shared build on Windows exports no symbols and does not install its
# DLL, so only static linkage is usable there.
if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO stotko/stdgpu
    # No release newer than 1.3.0 (2020-06); pin the tested master snapshot.
    REF 22599cfdcc185c2ed721d78c792e3193cf84cc01
    SHA512 de16413c81c7d95e48f2a5fbff018748e629a2316bc6c76c42f881b6922b337a12a1ec20eb732465ff244a04e22afe1846fdbacc9e4f2a72aa0204a0c11d397e
    HEAD_REF master
    # Current CCCL headers require the conforming MSVC preprocessor.
    PATCHES
        fix-msvc-preprocessor.patch
)

vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT CUDA_TOOLKIT_ROOT)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "dynamic" STDGPU_BUILD_SHARED_LIBS)

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DSTDGPU_BACKEND=STDGPU_BACKEND_CUDA
        -DSTDGPU_BUILD_SHARED_LIBS=${STDGPU_BUILD_SHARED_LIBS}
        -DSTDGPU_SETUP_COMPILER_FLAGS=OFF
        -DSTDGPU_COMPILE_WARNING_AS_ERROR=OFF
        -DSTDGPU_BUILD_EXAMPLES=OFF
        -DSTDGPU_BUILD_BENCHMARKS=OFF
        -DSTDGPU_BUILD_TESTS=OFF
        -DSTDGPU_BUILD_DOCUMENTATION=OFF
        -DSTDGPU_ENABLE_CONTRACT_CHECKS=OFF
        -DCMAKE_CUDA_COMPILER=${NVCC}
        -DCUDAToolkit_ROOT=${CUDA_TOOLKIT_ROOT}
        # Consistent with other CUDA ports (ginkgo, colmap); override via
        # VCPKG_CMAKE_CONFIGURE_OPTIONS if needed.
        -DCMAKE_CUDA_ARCHITECTURES=native
)

vcpkg_cmake_install()

vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/stdgpu)

vcpkg_copy_pdbs()

file(REMOVE_RECURSE
    "${CURRENT_PACKAGES_DIR}/debug/include"
    "${CURRENT_PACKAGES_DIR}/debug/share"
)

file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
