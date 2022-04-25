cmake_minimum_required(VERSION 3.20)

option(C_STANDARD "Check the supported c standard" "")
option(CXX_STANDARD "Check the supported cxx standard" "")

set(VCPKG_LANGUAGES "C;CXX" CACHE STRING "Languages to enables for this project")

project(requires_compiler_flags LANGUAGES ${VCPKG_LANGUAGES})

# Check c standard
include(CheckCCompilerFlag)
if (C_STANDARD)
    if (MSVC)
        check_c_compiler_flag(/std:c${C_STANDARD} c_standard_supported)
    else()
        check_c_compiler_flag(-std=c${C_STANDARD} c_standard_supported)
    endif()
    
    if (NOT c_standard_supported)
        message(FATAL_ERROR "The required c standard is not supported in this compiler")
    endif()
endif()

# Check cxx standard
include(CheckCXXCompilerFlag)
if (CXX_STANDARD)
    if (MSVC)
        check_cxx_compiler_flag(/std:c++${CXX_STANDARD} cxx_standard_supported)
    else()
        check_cxx_compiler_flag(-std=c++${CXX_STANDARD} cxx_standard_supported)
    endif()
    
    if (NOT cxx_standard_supported)
        message(FATAL_ERROR "The required c standard is not supported in this compiler")
    endif()
endif()
