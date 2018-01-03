cmake_minimum_required(VERSION 3.3)
project(vcpkg CXX)

add_compile_options(-std=c++1z)

if(CMAKE_COMPILER_IS_GNUXX OR CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    set(GCC 1)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "[Cc]lang")
    set(CLANG 1)
else()
    message(FATAL_ERROR "Unknown compiler: ${CMAKE_CXX_COMPILER_ID}")
endif()

file(GLOB_RECURSE VCPKGLIB_SOURCES src/vcpkg/*.cpp)

add_library(vcpkglib STATIC ${VCPKGLIB_SOURCES})
target_compile_definitions(vcpkglib PRIVATE -DDISABLE_METRICS=0)
target_include_directories(vcpkglib PUBLIC include)

if(GCC)
    target_link_libraries(vcpkglib PUBLIC stdc++fs)
elseif(CLANG)
    target_link_libraries(vcpkglib PUBLIC c++experimental)
endif()

add_executable(vcpkg src/vcpkg.cpp)
target_link_libraries(vcpkg PRIVATE vcpkglib)
