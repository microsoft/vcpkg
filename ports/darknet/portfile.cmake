vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

# There are no curated versions.
# Port updates must checkout the master branch, run
#   git describe --tags --dirty --long
# and put the result into this variable.
set(darknet_version_string "v5.0-167-gfc780f8a")

string(REGEX REPLACE "^.*-g" "" ref "${darknet_version_string}")
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO hank-ai/darknet
  REF "${ref}"
  SHA512 4403922273526862d6e899bfe4de2bc1205d004e8eb58f2a5837fda913565eff970405692d69f7c0155182a688d1ee91ca67f79edd1eae8c03228cdd24acac53
  HEAD_REF master
  PATCHES
    installation.diff
    purely-openmp_cxx-target.diff
    version-info.diff
    system-processor.diff
    windows-getopt.diff
)
file(WRITE "${SOURCE_PATH}/src-examples/CMakeLists.txt" "# disabled by vcpkg")
file(REMOVE_RECURSE "${SOURCE_PATH}/src-other")

# src-lib/col2im_kernels.cu, src-lib/gemm.cpp, src-lib/im2col.cpp, src-lib/im2col_kernels.cu
vcpkg_download_distfile(caffe_license_file
    URLS "https://github.com/BVLC/caffe/raw/9ab67099e08c03bf57e6a67538ca4746365beda8/LICENSE"
    FILENAME "hunk-ai-darknet-caffe-LICENSE-9ab6709"
    SHA512 333129c62f7c45df992ea4638d2b879608c1d01db80a5a6ce3e93970b414976374ef3e7b670f655b62f6fc4f8eb8c7ba17e94aad197e5e1a7ae8c0ef0b3587ba
)

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    cuda          DARKNET_TRY_CUDA
    openmp        VCPKG_LOCK_FIND_PACKAGE_OpenMP
)

if("cuda" IN_LIST FEATURES)
  vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root)
  list(APPEND FEATURE_OPTIONS "-DCMAKE_CUDA_COMPILER=${NVCC}")
  if(DEFINED CUDA_ARCHITECTURES)
    list(APPEND FEATURE_OPTIONS "-DDARKNET_CUDA_ARCHITECTURES=${CUDA_ARCHITECTURES}")
  else()
    message(STATUS "CUDA_ARCHITECTURES is not set. Choice is made by darknet.")
  endif()

  if(NOT "cudnn" IN_LIST FEATURES)
    list(APPEND FEATURE_OPTIONS "-Dcudnn=OFF") # disable find_library
  endif()
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  DISABLE_PARALLEL_CONFIGURE # configuring darknet_version.h
  OPTIONS
    ${FEATURE_OPTIONS}
    -DDARKNET_BRANCH_NAME=vcpkg # actually master with extra patches.
    -DDARKNET_VERSION_STRING=${darknet_version_string}
    -DDARKNET_TRY_ONNX=OFF
    -DDARKNET_TRY_OPENBLAS=OFF
    -DDARKNET_TRY_ROCM=OFF
    -DGTEST=OFF # disable find_library
    -DVCPKG_LOCK_FIND_PACKAGE_Doxygen=OFF
  MAYBE_UNUSED_VARIABLES
    DARKNET_TRY_OPENBLAS
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES darknet)
file(COPY "${CURRENT_PACKAGES_DIR}/share/${PORT}/cfg" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE" "${caffe_license_file}")
