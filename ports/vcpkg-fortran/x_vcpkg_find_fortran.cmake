#[===[.md:
# x_vcpkg_find_fortran

Checks if a Fortran compiler can be found.
Windows(x86/x64) Only: If it will try to enable the IntelOneAPI ifort compiler 
                       and return required cmake args for building. 

## Usage
```cmake
x_vcpkg_find_fortran(<additional_cmake_args_out>)
```
#]===]

function(x_vcpkg_find_fortran additional_cmake_args_out)
    set(ARGS_OUT)
    set(CMAKE_BINARY_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
    set(CMAKE_CURRENT_BINARY_DIR "${CMAKE_BINARY_DIR}")
    set(CMAKE_PLATFORM_INFO_DIR "${CMAKE_BINARY_DIR}/Platform")
    include(CMakeDetermineFortranCompiler)
    if(NOT CMAKE_Fortran_COMPILER AND NOT VCPKG_CHAINLOAD_TOOLCHAIN_FILE)
    # This intentionally breaks users with a custom toolchain which do not have a Fortran compiler setup
    # because they either need to use a port-overlay (for e.g. lapack), remove the toolchain for the port using fortran
    # or setup fortran in their VCPKG_CHAINLOAD_TOOLCHAIN_FILE themselfs!
        if(WIN32)
            message(STATUS "No Fortran compiler found on the PATH. Trying to find ifort!")
            set(PATH_SUFFIX "bin/intel64")
            if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
                string(APPEND PATH_SUFFIX "_ia32")
            endif()
            find_program(IFORT NAMES ifort PATHS ENV IFORT_COMPILER19 PATH_SUFFIXES "${PATH_SUFFIX}")
            if(NOT IFORT)
                message(FATAL_ERROR "ifort not found! Please install IntelOne API for HPC!")
            endif()
            find_file(SETVARS NAMES setvars.bat PATHS ENV ONEAPI_ROOT)
            if(NOT SETVARS)
                message(FATAL_ERROR "Batch file to setup IntelOneAPI not found! Please provide a correct ONEAPI_ROOT and make sure it contains setvars.bat!")
            endif()
            z_vcpkg_load_environment_from_batch(BATCH_FILE_PATH "${SETVARS}")
            list(APPEND ARGS_OUT "-DCMAKE_Fortran_COMPILER=${IFORT}"
                                 "-DCMAKE_Fortran_FLAGS_INIT:STRING=/Z7 /names:lowercase /assume:underscore /assume:protect_parens")
            set(VCPKG_USE_INTERNAL_Fortran TRUE CACHE INTERNAL "")
        else()
            message(FATAL_ERROR "Unable to find a Fortran compiler using 'CMakeDetermineFortranCompiler'. Please install one (e.g. gfortran) and make it available on the PATH!")
        endif()
    endif()
    set(${additional_cmake_args_out} ${ARGS_OUT} PARENT_SCOPE)
endfunction()
