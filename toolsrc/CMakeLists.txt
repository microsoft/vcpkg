cmake_minimum_required(VERSION 3.3)
project(vcpkg CXX)

if(CMAKE_COMPILER_IS_GNUXX OR CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    set(GCC 1)
elseif(CMAKE_CXX_COMPILER_ID MATCHES "[Cc]lang")
    set(CLANG 1)
elseif(MSVC)
    add_compile_options(/std:c++latest)
else()
    message(FATAL_ERROR "Unknown compiler: ${CMAKE_CXX_COMPILER_ID}")
endif()

if(GCC OR CLANG)
    add_compile_options(-std=c++1z)
endif()

file(GLOB_RECURSE VCPKGLIB_SOURCES src/vcpkg/*.cpp)

add_executable(vcpkg src/vcpkg.cpp ${VCPKGLIB_SOURCES})
target_compile_definitions(vcpkg PRIVATE -DDISABLE_METRICS=0)
target_include_directories(vcpkg PUBLIC include)

if(GCC)
    target_link_libraries(vcpkg PUBLIC stdc++fs)
elseif(CLANG)
    target_link_libraries(vcpkg PUBLIC c++experimental)
endif()
