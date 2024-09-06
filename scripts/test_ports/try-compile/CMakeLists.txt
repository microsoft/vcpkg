cmake_minimum_required(VERSION 3.25)

project(try-compile-test LANGUAGES C CXX)

try_compile(result PROJECT test-try-compile SOURCE_DIR  "${CMAKE_CURRENT_SOURCE_DIR}/try")

if(NOT result)
  message(FATAL_ERROR "Compiler flags are not passed consistently to try_compile!")
endif()