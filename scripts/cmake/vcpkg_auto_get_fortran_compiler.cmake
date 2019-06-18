## # vcpkg_auto_get_fortran_compiler
##
## Tries to detect a fortran compiler using CMakeDetermineFortranCompiler with some additional error checking.
##
##
## If the variable CMAKE_Fortran_COMPILER is not set at the end of this function an error will be raised.
##
## ## Usage:
## ```cmake
## vcpkg_auto_get_fortran_compiler()
## ```
##

function(vcpkg_auto_get_fortran_compiler)

    if(CMAKE_HOST_WIN32)
        file(TO_CMAKE_PATH "$ENV{PROGRAMFILES}" _programfiles)
        file(GLOB PGI_PATHS LIST_DIRECTORIES true "${_programfiles}/PGI/win64/*") # find possible PGI default paths
        foreach(_pgi_path ${PGI_PATHS})
            if(IS_DIRECTORY ${_pgi_path})
                if(EXISTS "${_pgi_path}/bin")
                    list(APPEND CMAKE_PROGRAM_PATH "${_pgi_path}/bin")
                endif()
            endif()
        endforeach()
        
        set(_PROGRAMFILESX86 "PROGRAMFILES(x86)")
        file(TO_CMAKE_PATH "$ENV{${_PROGRAMFILESX86}}" _programfiles_x86)
        if(EXISTS ${_programfiles_x86}/IntelSWTools/compilers_and_libraries/windows/bin/intel64)
            list(APPEND CMAKE_PROGRAM_PATH "${_programfiles_x86}/IntelSWTools/compilers_and_libraries/windows/bin/intel64")
            # Required so that CMake can link a test Fortran program using try_compile
            if(EXISTS ${_programfiles_x86}/IntelSWTools/compilers_and_libraries/windows/compiler/lib/intel64)
               vcpkg_add_to_lib("${_programfiles_x86}/IntelSWTools/compilers_and_libraries/windows/compiler/lib/intel64")
            endif()
        endif()
    endif()

    #CMake will generate some files. Setting these paths is enough to move those files into the buildtree
    set(_tmp_CMAKE_PLATFORM_INFO_DIR "${CMAKE_PLATFORM_INFO_DIR}")
    set(_tmp_CMAKE_BUILD_DIRECTORY "${CMAKE_BUILD_DIRECTORY}")
    set(_tmp_CMAKE_BINARY_DIR "${CMAKE_BINARY_DIR}")

    set(CMAKE_PLATFORM_INFO_DIR "${CURRENT_BUILDTREES_DIR}/cmake/${TARGET_TRIPLET}")
    set(CMAKE_BUILD_DIRECTORY "${CURRENT_BUILDTREES_DIR}/cmake/${TARGET_TRIPLET}")
    set(CMAKE_BINARY_DIR "${CURRENT_BUILDTREES_DIR}/cmake/${TARGET_TRIPLET}")

    # Find a Fortran compiler for us.
    # Can be overwritten by setting CMAKE_Fortran_COMPILER or the FC environment variable.
    # This does not currently work for cross-compilation
    include(CMakeDetermineFortranCompiler)
    set(CMAKE_PLATFORM_INFO_DIR "${_tmp_CMAKE_PLATFORM_INFO_DIR}")
    set(CMAKE_BUILD_DIRECTORY "${_tmp_CMAKE_BUILD_DIRECTORY}")
    set(CMAKE_BINARY_DIR "${_tmp_CMAKE_BINARY_DIR}")

    if(${CMAKE_Fortran_COMPILER} MATCHES "NOTFOUND")
        message(FATAL_ERROR "Fortran compiler could not automatically be detected. Please set the FC environment variable to the location of your compiler")
    else()
        message(STATUS "Using Fortran Compiler: ${CMAKE_Fortran_COMPILER}")
    endif()

    get_filename_component(_fort_comp_name ${CMAKE_Fortran_COMPILER} NAME)

    if(_fort_comp_name MATCHES "^pg")
        set(VCPKG_Fortran_IS_PGI 1 PARENT_SCOPE)
        if(NOT VCPKG_TARGET_ARCHITECTURE STREQUAL "x64") 
            # Support for 32-bit development was deprecated in PGI 2016 and is no longer available as of the PGI 2017 release. 
            # PGI 2017 is only available for 64-bit operating systems and does not include the ability to compile 32-bit applications
            message(FATAL_ERROR "PGI can only target x64.")
        endif()
    elseif(_fort_comp_name MATCHES "^ifort")
        set(VCPKG_Fortran_IS_INTEL 1 PARENT_SCOPE)
        get_filename_component(_Fortran_PATH "${CMAKE_Fortran_COMPILER}" DIRECTORY)
        
        if(DEFINED ENV{PROCESSOR_ARCHITEW6432})
            set(HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITEW6432})
        else()
            set(HOST_ARCHITECTURE $ENV{PROCESSOR_ARCHITECTURE})
        endif()
        
        if("$ENV{HOST_ARCHITECTURE}-${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "x86-x86")
            set(INTEL_ARCH "ia32")
        elseif("${HOST_ARCHITECTURE}-${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "x86-x64")
            set(INTEL_ARCH "ia32_intel64")
        elseif("${HOST_ARCHITECTURE}-${VCPKG_TARGET_ARCHITECTURE}" STREQUAL "AMD64-x64")
            set(INTEL_ARCH "intel64")
        else()
            message(FATAL_ERROR "Combination of host and target architecture is not supported by Intel")
        endif()

        if("${VCPKG_PLATFORM_TOOLSET}" STREQUAL "v140")
            set(INTEL_VS "vs2015")
        elseif("${VCPKG_PLATFORM_TOOLSET}" STREQUAL "v141")
            set(INTEL_VS "vs2017")
            # The Intel compilervars.bat expects the environment variable VS2017INSTALLDIR to be present so we set it
            if(NOT "$ENV{VS2017INSTALLDIR}")
                set(ENV{VS2017INSTALLDIR} "$ENV{VSINSTALLDIR}")
            endif()
        elseif("${VCPKG_PLATFORM_TOOLSET}" STREQUAL "v142")
            set(INTEL_VS "vs2019")
            # The Intel compilervars.bat expects the environment variable VS2019INSTALLDIR to be present so we set it
            if(NOT "$ENV{VS2019INSTALLDIR}")
                set(ENV{VS2019INSTALLDIR} "$ENV{VSINSTALLDIR}")
            endif()
        else()
            message(FATAL_ERROR "Visual Studio version is not supported by Intel")
        endif()
        _vcpkg_load_environment_from_batch(
            BATCH_FILE_PATH "${_Fortran_PATH}/../ifortvars.bat"
            ARGUMENTS
                ${INTEL_ARCH}
                ${INTEL_VS}
        )
    endif()
endfunction()
