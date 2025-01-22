cmake_minimum_required(VERSION 3.25)

project(try-compile-project LANGUAGES C CXX)

add_library(result "${CMAKE_CURRENT_SOURCE_DIR}/try-compile.c")

