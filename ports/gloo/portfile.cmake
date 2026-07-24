vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO facebookincubator/gloo
  REF 3135b0b41b67dde590eef0938a0bf3d6238df5f7
  SHA512 32a45ed9fe1f28cce3ca95640bd87b638c122c1a33cbb29f6761feb6ae0bd10db53de6f4abe79991e08797551b783b7244446f11a094c1707cc54ce4ecb29ad6
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
