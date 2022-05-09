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

include("${CMAKE_CURRENT_LIST_DIR}/z_vcpkg_load_environment_from_batch.cmake")
include("${_VCPKG_INSTALLED_DIR}/${_HOST_TRIPLET}/share/vcpkg-cmake/vcpkg_cmake_get_vars.cmake")

function(x_vcpkg_find_fortran)
     cmake_parse_arguments(PARSE_ARGV 0 "arg" "" "OUT_OPTIONS;OUT_OPTIONS_RELEASE;OUT_OPTIONS_DEBUG" "")

    vcpkg_list(SET additional_cmake_args)

    vcpkg_list(SET additional_cmake_args)
    vcpkg_cmake_get_vars(cmake_vars_file OPTIONS "-DVCPKG_LANGUAGES=C;CXX;Fortran")
    include("${cmake_vars_file}")

    if(NOT VCPKG_DETECTED_CMAKE_Fortran_COMPILER)
        if(WIN32)
            message(STATUS "Using internal Fortran Compiler ifort!")
            set(PATH_SUFFIX "bin/intel64")
            if(VCPKG_TARGET_ARCHITECTURE STREQUAL "x86")
                string(APPEND PATH_SUFFIX "_ia32")
            endif()
            set(search_path "${CURRENT_HOST_INSTALLED_DIR}/manual-tools/vcpkg-tool-ifort/Intel/Compiler/12.0")
            find_program(IFORT NAMES ifort${VCPKG_HOST_EXECUTABLE_SUFFIX} PATHS "${search_path}/compiler/2022.0.3/windows" PATH_SUFFIXES "${PATH_SUFFIX}" NO_DEFAULT_PATH)
            if(NOT IFORT)
                message(FATAL_ERROR "unable to find ifort in '${search_path}/compiler/2022.0.3/windows/bin'" )
            endif()
            find_file(SETVARS NAMES setvars.bat PATHS "${search_path}" NO_DEFAULT_PATH)
            unset(ENV{ONEAPI_ROOT}) # Otherwise the batch will load from from ONEAPI_ROOT
            z_vcpkg_load_environment_from_batch(BATCH_FILE_PATH "${SETVARS}")
            # if(VCPKG_TARGET_IS_UWP) # UWP is not supported since the Fortran libs are not build for UWP
            #    set(extra_uwp_flags "/NODEFAULTLIB /Qopenmp-stubs /D_UNICODE /DUNICODE /DWINAPI_FAMILY=WINAPI_FAMILY_APP /D__WRL_NO_DEFAULT_LIB__")
            #    set(exta_uwp_link_flags "-DCMAKE_SHARED_LINKER_FLAGS_INIT:STRING=/APPCONTAINER")
            # endif()

            vcpkg_list(APPEND additional_cmake_args 
"-DCMAKE_TRY_COMPILE_PLATFORM_VARIABLES=CMAKE_Fortran_FLAGS;CMAKE_Fortran_FLAGS_RELEASE;CMAKE_Fortran_FLAGS_DEBUG;CMAKE_Fortran_STANDARD_LIBRARIES;CMAKE_EXE_LINKER_FLAGS;CMAKE_EXE_LINKER_FLAGS_RELEASE;CMAKE_EXE_LINKER_FLAGS_DEBUG;CMAKE_STATIC_LINKER_FLAGS;CMAKE_STATIC_LINKER_FLAGS_DEBUG;CMAKE_STATIC_LINKER_FLAGS_RELEASE;CMAKE_SHARED_LINKER_FLAGS;CMAKE_SHARED_LINKER_FLAGS_RELEASE;CMAKE_SHARED_LINKER_FLAGS_DEBUG;CMAKE_REQUIRED_LINK_OPTIONS"
                "-DCMAKE_Fortran_COMPILER=${IFORT}"
                "-DCMAKE_Fortran_FLAGS_INIT:STRING=/Z7 /names:lowercase /assume:underscore /assume:protect_parens")
            set(Z_VCPKG_USE_INTERNAL_Fortran TRUE CACHE INTERNAL "")
            set(Z_VCPKG_IS_INTERNAL_Fortran_INTEL TRUE CACHE INTERNAL "")
        else()
            message(FATAL_ERROR "Unable to find a Fortran compiler using CMake. Please install one (e.g. gfortran) and make it available to CMake!")
        endif()
    endif()
    set("${arg_OUT_OPTIONS}" "${additional_cmake_args}" PARENT_SCOPE)
endfunction()
