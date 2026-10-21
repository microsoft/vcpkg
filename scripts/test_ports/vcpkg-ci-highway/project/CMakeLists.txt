cmake_minimum_required(VERSION 3.15)
project(vcpkg_ci_highway)

set(CMAKE_CXX_STANDARD 17)

find_package(hwy CONFIG REQUIRED)

# Dynamic Dispatch
add_executable(vcpkg_ci_highway main.cpp scale.cpp scale.hpp)
target_include_directories(vcpkg_ci_highway PRIVATE ${CMAKE_CURRENT_LIST_DIR})
target_link_libraries(vcpkg_ci_highway PRIVATE hwy::hwy)

# Static Dispatch
add_executable(vcpkg_ci_highway_static main.cpp scale.cpp scale.hpp)
target_include_directories(vcpkg_ci_highway_static PRIVATE ${CMAKE_CURRENT_LIST_DIR})
target_link_libraries(vcpkg_ci_highway_static PRIVATE hwy::hwy)
target_compile_definitions(vcpkg_ci_highway_static PRIVATE HWY_COMPILE_ONLY_STATIC)
