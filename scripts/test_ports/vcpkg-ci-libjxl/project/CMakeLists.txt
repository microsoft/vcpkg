cmake_minimum_required(VERSION 3.16)
project(libjxl-test C CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(PkgConfig REQUIRED)
pkg_check_modules(libjxl REQUIRED IMPORTED_TARGET libjxl libjxl_cms libjxl_threads)

add_executable(main-c main.c)
target_link_libraries(main-c PRIVATE PkgConfig::libjxl)

add_executable(main-cpp main.cpp)
target_link_libraries(main-cpp PRIVATE PkgConfig::libjxl)

install(TARGETS main-c main-cpp RUNTIME DESTINATION "bin/vcpkg-ci-libjxl")
