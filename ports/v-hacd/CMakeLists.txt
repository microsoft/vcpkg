cmake_minimum_required(VERSION 3.10.0 FATAL_ERROR)

project(VHACD)

# Determine if VHACD is built as a subproject (using add_subdirectory)
# or if it is the master project.
set(MASTER_PROJECT OFF)
if (CMAKE_CURRENT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    set(MASTER_PROJECT ON)
    message(STATUS "CMake version: ${CMAKE_VERSION}")
endif ()

option(NO_OPENCL "NO_OPENCL" OFF)
option(NO_OPENMP "NO_OPENMP" OFF)

message("NO_OPENCL " ${NO_OPENCL})
message("NO_OPENMP " ${NO_OPENMP})

add_subdirectory(src)