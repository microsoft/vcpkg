if(VCPKG_TARGET_IS_WINDOWS)
    vcpkg_check_linkage(ONLY_STATIC_LIBRARY)
endif()

vcpkg_download_distfile(
    MSVC_CUDA_PATCH
    URLS https://github.com/ginkgo-project/ginkgo/pull/1904.diff?full_index=1
    FILENAME msvc_cuda.patch
    SHA512 c8ed45f6775bdd42c4897720bf14488f9b01c5ea441153d15d380b63f1ae426c572eaff7a61349d1c2808314b6d68aa54e293b29a9414bbc2136e675f77b6705
)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO ginkgo-project/ginkgo
    REF "v${VERSION}"
    SHA512 b48f47c593172cf3a28ca926cf8e8dd2d080a7e0c4d4344fe9c1b60e036431d5e5ed93e2f67f56fb979eb6f03dad3f273594ca86dd0f6ddadd3b2e0bc3abde53
    HEAD_REF main
    PATCHES ${MSVC_CUDA_PATCH}
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
    openmp    GINKGO_BUILD_OMP
    cuda      GINKGO_BUILD_CUDA
    mpi       GINKGO_BUILD_MPI
    half      GINKGO_ENABLE_HALF
    bfloat16  GINKGO_ENABLE_BFLOAT16
)

if("cuda" IN_LIST FEATURES)
    vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root)
    list(APPEND FEATURE_OPTIONS
        "-DCMAKE_CUDA_COMPILER=${NVCC}"
        "-DCUDAToolkit_ROOT=${cuda_toolkit_root}"
        "-DCMAKE_CUDA_ARCHITECTURES=native"
     )
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        -DGINKGO_BUILD_REFERENCE=ON
        -DGINKGO_BUILD_TESTS=OFF
        -DGINKGO_BUILD_EXAMPLES=OFF
        -DGINKGO_BUILD_HIP=OFF
        -DGINKGO_BUILD_SYCL=OFF
        -DGINKGO_BUILD_HWLOC=OFF
        -DGINKGO_BUILD_BENCHMARKS=OFF
        -DGINKGO_DEVEL_TOOLS=OFF
        -DGINKGO_SKIP_DEPENDENCY_UPDATE=ON
        -DCMAKE_DISABLE_FIND_PACKAGE_Git=ON
        ${FEATURE_OPTIONS}
        ${CUDA_ARCHITECTURES_OPTION}
)

vcpkg_cmake_install()
vcpkg_cmake_config_fixup(CONFIG_PATH lib/cmake/Ginkgo)
vcpkg_fixup_pkgconfig()

file(INSTALL "${SOURCE_PATH}/LICENSE" DESTINATION "${CURRENT_PACKAGES_DIR}/share/ginkgo" RENAME copyright)
file(INSTALL "${CMAKE_CURRENT_LIST_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/ginkgo")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/include/CMakeFiles")
