cmake_minimum_required(VERSION 3.3)
project(vcpkg CXX)

add_compile_options(-std=c++1z)

file(GLOB_RECURSE VCPKGLIB_SOURCES src/vcpkg/*.cpp)

add_library(vcpkglib STATIC ${VCPKGLIB_SOURCES})
target_compile_definitions(vcpkglib PRIVATE -DDISABLE_METRICS=0)
target_include_directories(vcpkglib PUBLIC include)
target_link_libraries(vcpkglib PRIVATE stdc++fs)

add_executable(vcpkg src/vcpkg.cpp)
target_link_libraries(vcpkg PRIVATE vcpkglib)
