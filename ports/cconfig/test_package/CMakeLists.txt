cmake_minimum_required(VERSION 3.10)
project(cconfig-test C)

find_path(CCONFIG_INCLUDE_DIRS "cconfig.h" PATH_SUFFIXES "include")

add_executable(cconfig-test test.c)

target_include_directories(cconfig-test PRIVATE ${CCONFIG_INCLUDE_DIRS})
