cmake_minimum_required(VERSION 3.10)
project(cconfig-test C)

find_package(cconfig CONFIG REQUIRED)

add_executable(cconfig-test test.c)

# For a header-only library, this primarily adds the include directories.
target_link_libraries(cconfig-test PRIVATE cconfig::cconfig)

message(STATUS "Successfully found and linked cconfig.")