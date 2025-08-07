cmake_minimum_required(VERSION 3.29)
project(crashpad-test CXX)

set(CMAKE_CXX_STANDARD 11)

add_executable(main main.cpp)

find_package(crashpad CONFIG REQUIRED)
target_link_libraries(main PRIVATE crashpad::crashpad)
