vcpkg_check_linkage(ONLY_DYNAMIC_LIBRARY)

vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO hank-ai/darknet
  # git ref v5.1 is ambiguous, https://github.com/hank-ai/darknet/issues/140
  REF e1720f444420ffd354004e873219c6d8457a8735
  SHA512 4b33b11696a6e891e51cd9c3f9636793e5c6bc7fd4eaeebe1c42595fbf918c9f466a9c34ab9b1a5f863d29695f7db63f7359867b3566706a662a837e6404155e
  HEAD_REF master
  PATCHES
    install-dir.diff
    version-info.diff
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
    "-DDARKNET_VERSION_STRING=${VERSION}-vcpkg"
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
file(COPY "${SOURCE_PATH}/cfg" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
