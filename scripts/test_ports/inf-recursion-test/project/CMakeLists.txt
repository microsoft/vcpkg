cmake_minimum_required(VERSION 3.18)

# vcpkg can only guard against overrides before the first project() call!
macro(find_package)
    _find_package(${ARGV})
endmacro()

function(add_library)
    _add_library(${ARGV})
endfunction()

function(add_executable)
    _add_executable(${ARGV})
endfunction()

project(inf-recursion-test)

find_package(ZLIB REQUIRED)
add_library(mylib lib.cpp)
add_executable(myexe main.cpp)