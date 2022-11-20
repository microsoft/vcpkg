
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
else()
  message(FATAL_ERROR "Please install NCCL using your system package manager (the same way you installed CUDA). For example: apt install libnccl2 libnccl-dev.")
endif()

file(INSTALL "${CURRENT_PORT_DIR}/FindNCCL.cmake" DESTINATION "${CURRENT_PACKAGES_DIR}/share/${PORT}")
configure_file("${CURRENT_PORT_DIR}/vcpkg-cmake-wrapper.cmake" "${CURRENT_PACKAGES_DIR}/share/${PORT}/vcpkg-cmake-wrapper.cmake" @ONLY)
file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
