cmake_minimum_required(VERSION 3.16)
# Do not unconditionally enable Fortran here.
project(vcpkg-ci-fortran C CXX)

if(NOT EXPECTED_C_COMPILER STREQUAL CMAKE_C_COMPILER)
    message(SEND_ERROR "Unexpect C compiler\n   actual:   ${CMAKE_C_COMPILER}\n   expected: ${EXPECTED_C_COMPILER}")
endif()
if(NOT EXPECTED_CXX_COMPILER STREQUAL CMAKE_CXX_COMPILER)
    message(SEND_ERROR "Unexpect CXX compiler\n   actual:   ${CMAKE_CXX_COMPILER}\n   expected: ${EXPECTED_CXX_COMPILER}")
endif()

# Enable build with gfortran for MSVC.
include(CMakeAddFortranSubdirectory)
cmake_add_fortran_subdirectory(f NO_EXTERNAL_INSTALL)

# Enable link with gfortran for NOT MSVC.
if(NOT MINGW_GFORTRAN)
    enable_language(Fortran)
endif()

add_executable(main main.cxx)
target_link_libraries(main flib)
