cmake_minimum_required(VERSION 3.3)
project(vcpkg CXX)

file(GLOB_RECURSE VCPKGLIB_SOURCES src/vcpkg/*.cpp)

add_library(vcpkglib STATIC ${VCPKGLIB_SOURCES})
target_compile_definitions(vcpkglib PRIVATE -DDISABLE_METRICS=0)
target_include_directories(vcpkglib PUBLIC include)

if(CMAKE_COMPILER_IS_GNUXX)
    target_link_libraries(vcpkglib PRIVATE stdc++fs)
    target_compile_options(vcpkglib PRIVATE -std=c++1z)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "[Cc]lang")
    target_link_libraries(vcpkglib PRIVATE c++experimental)
    target_compile_options(vcpkglib PRIVATE -std=c++1z)
endif()

add_executable(vcpkg src/vcpkg.cpp)
target_link_libraries(vcpkg PRIVATE vcpkglib)
