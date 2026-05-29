cmake_minimum_required(VERSION 3.16)
project(pixman-test CXX)

find_package(PkgConfig REQUIRED)

pkg_search_module(pixman REQUIRED pixman-1 IMPORTED_TARGET)

add_executable(main main.cpp)
target_link_libraries(main PRIVATE PkgConfig::pixman)
