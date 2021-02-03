vcpkg_fail_port_install(ON_TARGET "Windows" "OSX" ON_ARCH "x86" "arm")

# note: this port must be kept in sync with CUDA port: every time one is upgraded, the other must be too
# Minimum version to find -- should match the CUDA port's minimum version's corresponding cuDNN version
set(NCCL_VERSION "2.4.6.1")
string(REPLACE "." ";" VERSION_LIST ${NCCL_VERSION})
list(GET VERSION_LIST 0 NCCL_VERSION_MAJOR)
list(GET VERSION_LIST 1 NCCL_VERSION_MINOR)
list(GET VERSION_LIST 2 NCCL_VERSION_PATCH)

# Try to find NCCL if it exists
set(NCCL_PREV_MODULE_PATH ${CMAKE_MODULE_PATH})
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_LIST_DIR})
find_package(NCCL ${NCCL_VERSION})
set(CMAKE_MODULE_PATH ${NCCL_PREV_MODULE_PATH})

# Download only if the CUDA version is exactly 10.1 (which matches the vcpkg CUDA port required version), else fail
if(NCCL_FOUND)
  message(STATUS "Using NCCL located on system.")
  set(VCPKG_POLICY_EMPTY_PACKAGE enabled)
else()
  message(FATAL_ERROR "Could not find NCCL. Before continuing, please download and install a NCCL version "
    "\nthat matches your CUDA version from:"
    "\n    https://developer.nvidia.com/nccl\n")
endif()

file(INSTALL "${CURRENT_PORT_DIR}/usage" DESTINATION ${CURRENT_PACKAGES_DIR}/share/${PORT})
