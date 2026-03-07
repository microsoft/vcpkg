cmake_minimum_required(VERSION 3.10)
project(halftest)

find_path(HALF_INCLUDE_DIRS "half.hpp")
add_executable(main main.cpp)
target_include_directories(main PRIVATE ${HALF_INCLUDE_DIRS})
