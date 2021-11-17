cmake_minimum_required(VERSION 3.17)

project(Find_LAPACK_external)

find_package(LAPACK REQUIRED)

if(NOT LAPACK_FOUND)
    message(FATAL_ERROR "Expected LAPACK_FOUND to be true")
endif()
if(NOT TARGET LAPACK::LAPACK)
    message(FATAL_ERROR "Expected LAPACK::LAPACK to be a valid target")
endif()
if(NOT DEFINED LAPACK_LIBRARIES)
    message(FATAL_ERROR "Expected LAPACK_LIBRARIES to be defined")
endif()
