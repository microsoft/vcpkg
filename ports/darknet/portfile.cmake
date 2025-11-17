vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO hank-ai/darknet
  REF v5.0
  SHA512 f19e8ff82111ce12da2cb06d7b4de18a2a965c67197f5d54b77a5502f658c4e837e2f346e2c8d24ad3f2bb1352845a35db665ac6f5455c022ffb1f37ad31f217
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
    "-DDARKNET_BRANCH_NAME=vcpkg"
    "-DDARKNET_VERSION_SHORT=${VERSION}"
    "-DDARKNET_VERSION_STRING=${VERSION}"
    -DDARKNET_TRY_ROCM=OFF
    -DVCPKG_LOCK_FIND_PACKAGE_Doxygen=OFF
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES darknet)
file(COPY "${SOURCE_PATH}/cfg" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
