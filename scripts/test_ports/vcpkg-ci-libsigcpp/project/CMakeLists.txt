cmake_minimum_required(VERSION 3.10)
project(vcpkg_ci_libsigcpp)

set(CMAKE_CXX_STANDARD 17)

find_package(sigc++-3 CONFIG REQUIRED)

add_executable(vcpkg_ci_libsigcpp main.cpp)
target_link_libraries(vcpkg_ci_libsigcpp PRIVATE sigc-3.0)
