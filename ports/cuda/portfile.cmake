# Due to the complexity involved, this package doesn't install CUDA. It instead verifies that CUDA is installed.
# Other packages can depend on this package to declare a dependency on CUDA.
# If this package is installed, we assume that CUDA is properly installed.

execute_process(
        COMMAND nvcc --version
        OUTPUT_VARIABLE NVCC_OUTPUT
        RESULT_VARIABLE error_code)

# Sample output
# NVIDIA (R) Cuda compiler driver
# Copyright (c) 2005-2016 NVIDIA Corporation
# Built on Sat_Sep__3_19:05:48_CDT_2016
# Cuda compilation tools, release 8.0, V8.0.44
set(CUDA_REQUIRED_VERSION "V8.0.0")

if (${error_code})
    message(FATAL_ERROR "CUDA is not installed. Before continuing, please download and install CUDA  (${CUDA_REQUIRED_VERSION} or higher) from:"
                        "\n    https://developer.nvidia.com/cuda-downloads \n")
endif()

string(REGEX MATCH "V([0-9]+)\\.([0-9]+)\\.([0-9]+)" CUDA_VERSION ${NVCC_OUTPUT})
message(STATUS "Found CUDA ${CUDA_VERSION}")
set(CUDA_VERSION_MAJOR ${CMAKE_MATCH_1})
#set(CUDA_VERSION_MINOR ${CMAKE_MATCH_2})
#set(CUDA_VERSION_PATCH ${CMAKE_MATCH_3})


if (${CUDA_VERSION_MAJOR} LESS 8)
    message(FATAL_ERROR "CUDA ${CUDA_VERSION} but ${CUDA_REQUIRED_VERSION} is required. Please download and install a more recent version of CUDA from:"
                        "\n    https://developer.nvidia.com/cuda-downloads \n")
endif()

SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)