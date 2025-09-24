cmake_minimum_required(VERSION 3.10)
project(cconfig-test C)

# Use the include path installed by vcpkg
find_path(CCONFIG_INCLUDE_DIRS "cconfig.h"
  PATH_SUFFIXES "cconfig"
  HINTS "${CMAKE_CURRENT_LIST_DIR}/../include"
)

if(NOT CCONFIG_INCLUDE_DIRS)
    message(FATAL_ERROR "Could not find cconfig.h in the include path")
endif()

# Create a test executable
add_executable(cconfig-test test.c)

# Add include directories
target_include_directories(cconfig-test PRIVATE ${CCONFIG_INCLUDE_DIRS})
