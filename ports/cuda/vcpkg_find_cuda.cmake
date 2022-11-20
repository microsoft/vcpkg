function(vcpkg_find_cuda)
    cmake_parse_arguments(PARSE_ARGV 0 vfc "" "OUT_CUDA_TOOLKIT_ROOT;OUT_CUDA_VERSION" "")

    if(NOT vfc_OUT_CUDA_TOOLKIT_ROOT)
        message(FATAL_ERROR "vcpkg_find_cuda() requres an OUT_CUDA_TOOLKIT_ROOT argument")
    endif()

    set(CUDA_REQUIRED_VERSION "10.1.0")

    set(CUDA_PATHS
            ENV CUDA_PATH
            ENV CUDA_HOME
            ENV CUDA_BIN_PATH
            ENV CUDA_TOOLKIT_ROOT_DIR)

    if (VCPKG_TARGET_IS_WINDOWS)
        find_program(NVCC
            NAMES nvcc.exe
            PATHS
            ${CUDA_PATHS}
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
                if (p_version VERSION_GREATER_EQUAL CUDA_REQUIRED_VERSION)
                    set(FOUND_PATH ${p})
                    break()
                endif()
            endif()
        endforeach()

        vcpkg_list(APPEND CUDA_PATHS /usr/bin)

        find_program(NVCC
            NAMES nvcc
            PATHS
            ${CUDA_PATHS}
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
        message(STATUS "Executing ${NVCC} --version resulted in error: ${error_code}")
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
    set(CUDA_VERSION_MAJOR "${CMAKE_MATCH_1}")
    set(CUDA_VERSION_MINOR "${CMAKE_MATCH_2}")
    set(CUDA_VERSION_MAJOR_MINOR "${CMAKE_MATCH_1}.${CMAKE_MATCH_2}")

    if (CUDA_VERSION_MAJOR_MINOR VERSION_LESS CUDA_REQUIRED_VERSION)
      message(FATAL_ERROR "CUDA v${CUDA_VERSION_MAJOR_MINOR} found, but v${CUDA_REQUIRED_VERSION} is required. Please download and install a more recent version of CUDA from:"
                            "\n    https://developer.nvidia.com/cuda-downloads\n")
    endif()

    get_filename_component(CUDA_TOOLKIT_ROOT "${NVCC}" DIRECTORY)
    get_filename_component(CUDA_TOOLKIT_ROOT "${CUDA_TOOLKIT_ROOT}" DIRECTORY)
    set(${vfc_OUT_CUDA_TOOLKIT_ROOT} "${CUDA_TOOLKIT_ROOT}" PARENT_SCOPE)
    if(DEFINED vfc_OUT_CUDA_VERSION)
        set(${vfc_OUT_CUDA_VERSION} "${CUDA_VERSION_MAJOR_MINOR}" PARENT_SCOPE)
    endif()
endfunction()
