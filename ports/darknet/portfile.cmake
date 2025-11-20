vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

# There are no curated versions.
# Port updates must checkout the master branch, run
#   git describe --tags --dirty --long
# and put the result into this variable.
set(darknet_version_string "v5.0-167-gfc780f8a")
# We take from master but we also add patches.
set(darknet_branch_name vcpkg)

string(REGEX REPLACE "^.*-g" "" ref "${darknet_version_string}")
vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO hank-ai/darknet
  REF "${ref}"
  SHA512 4403922273526862d6e899bfe4de2bc1205d004e8eb58f2a5837fda913565eff970405692d69f7c0155182a688d1ee91ca67f79edd1eae8c03228cdd24acac53
  HEAD_REF master
  PATCHES
    installation.diff
    version-info.diff
    system-processor.diff
    windows-getopt.diff
)
file(WRITE "${SOURCE_PATH}/src-examples/CMakeLists.txt" "# disabled by vcpkg")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    cuda          DARKNET_TRY_CUDA
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
    "-DDARKNET_BRANCH_NAME=${darknet_branch_name}"
    "-DDARKNET_VERSION_STRING=${darknet_version_string}"
    -DDARKNET_TRY_ONNX=OFF
    -DDARKNET_TRY_OPENBLAS=OFF
    -DDARKNET_TRY_ROCM=OFF
    -DVCPKG_LOCK_FIND_PACKAGE_Doxygen=OFF
    -DGTEST=OFF # disable find_library
    --trace-expand
  MAYBE_UNUSED_VARIABLES
    DARKNET_TRY_OPENBLAS
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES darknet)
file(COPY "${SOURCE_PATH}/cfg" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
