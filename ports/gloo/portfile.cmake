vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO facebookincubator/gloo
  REF bcd1672ee07538123ea8f4fac76832efc58fb8ef
  SHA512 3724c14b715aad9b7f72c3b576c7395d2285e8b55ff3a2cf5263c1df4c8275f04e8854696588977501384cbd0a75e0156f406b7d2465e439cd02bd3214df9bf0
  HEAD_REF master
)

# Determine which backend to build via specified feature
vcpkg_check_features(
  OUT_FEATURE_OPTIONS GLOO_FEATURE_OPTIONS
  FEATURES
  mpi USE_MPI
  redis USE_REDIS
  cuda USE_CUDA
  cuda USE_NCCL
  )

if ("cuda" IN_LIST FEATURES)
  vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root)
  list(APPEND GLOO_FEATURE_OPTIONS
    "-DCMAKE_CUDA_COMPILER:FILEPATH=${NVCC}"
    "-DCUDAToolkit_ROOT=${cuda_toolkit_root}"
    "-DCMAKE_CUDA_STANDARD=20"
    "-DGLOO_USE_CUDA_TOOLKIT=ON"
  )
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  OPTIONS ${GLOO_FEATURE_OPTIONS}
  MAYBE_UNUSED_VARIABLES
    CMAKE_CUDA_COMPILER
    CUDAToolkit_ROOT
  )
vcpkg_cmake_install()
vcpkg_copy_pdbs()

vcpkg_cmake_config_fixup(CONFIG_PATH share/cmake/Gloo)
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
