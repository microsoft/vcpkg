set(MINIMUM_CUDNN_VERSION "7.6.5")

vcpkg_find_cuda(OUT_CUDA_TOOLKIT_ROOT CUDA_TOOLKIT_ROOT OUT_CUDA_VERSION CUDA_VERSION)

include("${CURRENT_PORT_DIR}/FindCUDNN.cmake")

if (CUDNN_INCLUDE_DIR AND CUDNN_LIBRARY AND _CUDNN_VERSION VERSION_GREATER_EQUAL MINIMUM_CUDNN_VERSION)
  message(STATUS "Found CUDNN ${_CUDNN_VERSION} located on system: (include ${CUDNN_INCLUDE_DIR} lib: ${CUDNN_LIBRARY})")
  set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
elseif(VCPKG_TARGET_IS_WINDOWS)
  message(FATAL_ERROR "Please download CUDNN from official sources (https://developer.nvidia.com/cudnn) and install it")
else()
  message(FATAL_ERROR "Please install CUDNN using your system package manager (the same way you installed CUDA). For example: apt install libcudnn8-dev.")
endif()

file(INSTALL "${CURRENT_PORT_DIR}/FindCUDNN.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
file(INSTALL "${CURRENT_PORT_DIR}/vcpkg-cmake-wrapper.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
