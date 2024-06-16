cmake_minimum_required(VERSION 3.8)
project(glad C CXX)

add_subdirectory(cmake)
glad_add_library(glad_gl_core_46 STATIC REPRODUCIBLE API gl:core=4.6)