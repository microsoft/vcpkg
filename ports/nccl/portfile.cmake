vcpkg_fail_port_install(ON_TARGET "Windows" "OSX" ON_ARCH "x86" "arm")

# Find NCCL. We can use FindNCCL directly since it doesn't call any functions
# that are disallowed in CMake script mode
set(MINIMUM_NCCL_VERSION "2.4.6.1")
set(NCCL_PREV_MODULE_PATH ${CMAKE_MODULE_PATH})
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
find_package(NCCL ${MINIMUM_NCCL_VERSION})
set(CMAKE_MODULE_PATH ${NCCL_PREV_MODULE_PATH})

# Download or return
if(NCCL_FOUND)
  message(STATUS "Using NCCL ${_NCCL_VERSION} located on system.")
  set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
elseif(VCPKG_TARGET_IS_WINDOWS)
  message(FATAL_ERROR "Please download NCCL from official sources (such as https://developer.nvidia.com/nccl ) and extract the zip into your CUDA_TOOLKIT_ROOT (${CUDA_TOOLKIT_ROOT})")
else()
  message(FATAL_ERROR "Please install NCCL using your system package manager (the same way you installed CUDA). For example: apt install libnccl2 libnccl-dev.")
endif()

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
