vcpkg_from_github(
  OUT_SOURCE_PATH SOURCE_PATH
  REPO AlexeyAB/darknet
  REF 19dde2f296941a75b0b9202cccd59528bde7f65a
  SHA512 3f24fd5c69a00032e63fc8479d46dedf9008909c5e0f37847f0427c39f35e68f35a5ee89820cd0a179cb282e49730e6b1465a027d89bef585e9a1cfca6e3d3a2
  HEAD_REF master
  PATCHES
    android.diff
    msvc-names.diff
)
file(REMOVE_RECURSE "${SOURCE_PATH}/3rdparty")
file(REMOVE_RECURSE "${SOURCE_PATH}/cmake/Modules")

vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
  FEATURES
    cuda          ENABLE_CUDA
    cudnn         ENABLE_CUDNN
    opencv-base   ENABLE_OPENCV
)

if("cuda" IN_LIST FEATURES)
    vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT cuda_toolkit_root)
    list(APPEND FEATURE_OPTIONS "-DCMAKE_CUDA_COMPILER=${NVCC}")
endif()

vcpkg_cmake_configure(
  SOURCE_PATH "${SOURCE_PATH}"
  DISABLE_PARALLEL_CONFIGURE
  OPTIONS
    ${FEATURE_OPTIONS}
    -DINSTALL_BIN_DIR:STRING=bin
    -DINSTALL_LIB_DIR:STRING=lib
    -DSKIP_INSTALL_RUNTIME_LIBS:BOOL=ON
)
vcpkg_cmake_install()
vcpkg_cmake_config_fixup()

vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES darknet uselib kmeansiou)
if ("opencv-cuda" IN_LIST FEATURES)
  vcpkg_copy_tools(AUTO_CLEAN TOOL_NAMES uselib_track)
endif()
file(COPY "${SOURCE_PATH}/cfg" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(COPY "${SOURCE_PATH}/data" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
file(INSTALL "${SOURCE_PATH}/scripts/download_weights.ps1" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/scripts")

file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/share")
file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/debug/include")

message(STATUS "To download weight files, please go to ${CURRENT_INSTALLED_DIR}/tools/${PORT}/scripts and run ./download_weights.ps1")

vcpkg_install_copyright(FILE_LIST "${SOURCE_PATH}/LICENSE")
