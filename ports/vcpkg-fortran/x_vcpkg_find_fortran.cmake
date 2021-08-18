#[===[.md:
# x_vcpkg_find_fortran

Checks if a Fortran compiler can be found.
Windows(x86/x64) Only: If not it will search and enable Intel
                       ifort compiler if available. 

## Usage
```cmake
x_vcpkg_find_fortran(<out_var>)
```

## Example
```cmake
x_vcpkg_find_fortran(fortran_args)
# ...
vcpkg_configure_cmake(...
    OPTIONS
        ${fortran_args}
)
```
#]===]


function(x_vcpkg_find_fortran out_var)
    if("${ARGC}" GREATER "1")
        message(WARNING "${CMAKE_CURRENT_FUNCTION} was passed extra args: ${ARGN}")
    endif()

    vcpkg_list(SET additional_cmake_args)

    set(CMAKE_BINARY_DIR "${CURRENT_BUILDTREES_DIR}/${TARGET_TRIPLET}")
    set(CMAKE_CURRENT_BINARY_DIR "${CMAKE_BINARY_DIR}")
    set(CMAKE_PLATFORM_INFO_DIR "${CMAKE_BINARY_DIR}/Platform")
    include(CMakeDetermineFortranCompiler)

    if(NOT CMAKE_Fortran_COMPILER AND "${VCPKG_CHAINLOAD_TOOLCHAIN_FILE}" STREQUAL "")
        # If a user uses their own VCPKG_CHAINLOAD_TOOLCHAIN_FILE, they _must_ figure out Fortran on their own. 
        if(WIN32)
            message(STATUS "No Fortran compiler found on the PATH. Trying to find and use ifort!")
            set(PATH_SUFFIX "bin/intel64")
            if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
                string(APPEND PATH_SUFFIX "_ia32")
            endif()
            find_program(IFORT NAMES ifort PATHS ENV IFORT_COMPILER21 IFORT_COMPILER20 IFORT_COMPILER19 PATH_SUFFIXES "${PATH_SUFFIX}")
            if(NOT IFORT)
                message(FATAL_ERROR "ifort not found! Please install ifort from the Intel oneAPI for HPC toolkit: https://software.intel.com/content/www/us/en/develop/tools/oneapi/hpc-toolkit/download.html!")
            endif()
            find_file(SETVARS NAMES setvars.bat PATHS ENV ONEAPI_ROOT)
            if(NOT SETVARS)
                message(FATAL_ERROR "Batch file to setup Intel oneAPI not found! Please provide a correct ONEAPI_ROOT and make sure it contains setvars.bat!")
            endif()
            z_vcpkg_load_environment_from_batch(BATCH_FILE_PATH "${SETVARS}")
            if(VCPKG_TARGET_IS_UWP)
                set(extra_uwp_flags "/NODEFAULTLIB /Qopenmp-stubs /D_UNICODE /DUNICODE /DWINAPI_FAMILY=WINAPI_FAMILY_APP /D__WRL_NO_DEFAULT_LIB__")
                set(exta_uwp_link_flags "-DCMAKE_SHARED_LINKER_FLAGS_INIT:STRING=/APPCONTAINER")
            endif()

            vcpkg_list(APPEND additional_cmake_args
                "-DCMAKE_Fortran_COMPILER=${IFORT}"
                "-DCMAKE_Fortran_FLAGS_INIT:STRING=/Z7 /names:lowercase /assume:underscore /assume:protect_parens ${extra_uwp_flags}"
                "${exta_uwp_link_flags}")
            set(VCPKG_USE_INTERNAL_Fortran TRUE CACHE INTERNAL "")
        else()
            message(FATAL_ERROR "Unable to find a Fortran compiler using 'CMakeDetermineFortranCompiler'. Please install one (e.g. gfortran) and make it available on the PATH!")
        endif()
    endif()
    set("${out_var}" "${additional_cmake_args}" PARENT_SCOPE)
endfunction()
