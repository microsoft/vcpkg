vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO facebookresearch/faiss
    REF "v${VERSION}"
    SHA512 c1cbf92a96dfee0a27dc0cb8d719a451efec6ea44a73bd4a8b764593624bc0e074da5aa6bca19fbc904899416aab2a82aa5659d06bb07174624cb4449252ac07
    HEAD_REF main
    PATCHES
        msvc-template.diff
        undef-small.diff
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        gpu     FAISS_ENABLE_GPU
)

if ("gpu" IN_LIST FEATURES)
    vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root)
    list(APPEND FEATURE_OPTIONS
        "-DCMAKE_CUDA_COMPILER=${NVCC}"
        "-DCUDAToolkit_ROOT=${cuda_toolkit_root}"
    )
    if(VCPKG_TARGET_IS_WINDOWS)
        # See https://github.com/NVIDIA/cuda-samples/pull/412
        list(APPEND FEATURE_OPTIONS "-DCMAKE_CUDA_FLAGS_INIT=-Xcompiler=/Zc:preprocessor")
    endif()
endif()

vcpkg_cmake_configure(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS
        ${FEATURE_OPTIONS}
        -DFAISS_ENABLE_MKL=OFF
        -DFAISS_ENABLE_PYTHON=OFF  # Requires SWIG
        -DBUILD_TESTING=OFF
)

vcpkg_cmake_install()
vcpkg_copy_pdbs()
vcpkg_cmake_config_fixup()

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
