# This package doesn't install CUDA. It instead verifies that CUDA is installed.
# Other packages can depend on this package to declare a dependency on CUDA.
# If this package is installed, we assume that CUDA is properly installed.

#note: this port must be kept in sync with CUDNN port: every time one is upgraded, the other must be too
set(CUDA_REQUIRED_VERSION "10.1.0")

if (VCPKG_TARGET_IS_WINDOWS)
    find_program(NVCC
        NAMES nvcc.exe
        PATHS
        ENV CUDA_PATH
        ENV CUDA_BIN_PATH
        PATH_SUFFIXES bin bin64
        DOC "Toolkit location."
        NO_DEFAULT_PATH
    )
else()
    if (VCPKG_TARGET_IS_LINUX)
        set(platform_base "/usr/local/cuda-")
    else()
        set(platform_base "/Developer/NVIDIA/CUDA-")
    endif()
    
    file(GLOB possible_paths "${platform_base}*")
    set(FOUND_PATH )
    foreach (p ${possible_paths})
        # Extract version number from end of string
        string(REGEX MATCH "[0-9][0-9]?\\.[0-9]$" p_version ${p})
        if (IS_DIRECTORY ${p} AND p_version)
            message("FOUND_PATH : ${p}")
            if (p_version VERSION_GREATER_EQUAL CUDA_REQUIRED_VERSION)
                set(FOUND_PATH ${p})
                break()
            endif()
        endif()
    endforeach()
    
    find_program(NVCC
        NAMES nvcc
        PATHS
        ENV CUDA_PATH
        ENV CUDA_BIN_PATH
        PATHS ${FOUND_PATH}
        PATH_SUFFIXES bin bin64
        DOC "Toolkit location."
        NO_DEFAULT_PATH
    )
endif()

set(error_code 1)
if (NVCC)
    execute_process(
        COMMAND ${NVCC} --version
        OUTPUT_VARIABLE NVCC_OUTPUT
        RESULT_VARIABLE error_code)
endif()


if (error_code)
    message(FATAL_ERROR "Could not find CUDA. Before continuing, please download and install CUDA (v${CUDA_REQUIRED_VERSION} or higher) from:"
                        "\n    https://developer.nvidia.com/cuda-downloads\n")
endif()

# Sample output:
# NVIDIA (R) Cuda compiler driver
# Copyright (c) 2005-2016 NVIDIA Corporation
# Built on Sat_Sep__3_19:05:48_CDT_2016
# Cuda compilation tools, release 8.0, V8.0.44
string(REGEX MATCH "V([0-9]+)\\.([0-9]+)\\.([0-9]+)" CUDA_VERSION ${NVCC_OUTPUT})
message(STATUS "Found CUDA ${CUDA_VERSION}")
set(CUDA_VERSION_MAJOR ${CMAKE_MATCH_1})
set(CUDA_VERSION_MINOR ${CMAKE_MATCH_2})
set(CUDA_VERSION_PATCH ${CMAKE_MATCH_3})

if (CUDA_VERSION_MAJOR LESS 10 AND CUDA_VERSION_MINOR LESS 1)
    message(FATAL_ERROR "CUDA ${CUDA_VERSION} found, but v${CUDA_REQUIRED_VERSION} is required. Please download and install a more recent version of CUDA from:"
                        "\n    https://developer.nvidia.com/cuda-downloads\n")
endif()

SET(VCPKG_POLICY_EMPTY_PACKAGE enabled)
