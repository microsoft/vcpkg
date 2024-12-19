cmake_minimum_required(VERSION 3.16)
project(vcpkg-ci-fortran C CXX)

if(NOT EXPECTED_C_COMPILER STREQUAL CMAKE_C_COMPILER)
    message(SEND_ERROR "Unexpect C compiler\n   actual:   ${CMAKE_C_COMPILER}\n   expected: ${EXPECTED_C_COMPILER}")
endif()
if(NOT EXPECTED_CXX_COMPILER STREQUAL CMAKE_CXX_COMPILER)
    message(SEND_ERROR "Unexpect CXX compiler\n   actual:   ${CMAKE_CXX_COMPILER}\n   expected: ${EXPECTED_CXX_COMPILER}")
endif()

include(CMakeAddFortranSubdirectory)
cmake_add_fortran_subdirectory(f NO_EXTERNAL_INSTALL)
