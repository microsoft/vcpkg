cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(nanobench LANGUAGES CXX)

include(GNUInstallDirs)

add_library(nanobench STATIC "${CMAKE_SOURCE_DIR}/src/test/app/nanobench.cpp")
add_library(nanobench::nanobench ALIAS nanobench)
set_property(TARGET nanobench PROPERTY CXX_STANDARD 17)
target_include_directories(nanobench PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/src/include>"
    "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>")

install(TARGETS nanobench EXPORT nanobench)

install(
    EXPORT nanobench
    FILE nanobench-config.cmake
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/nanobench"
    NAMESPACE nanobench::
)

install(FILES "${CMAKE_SOURCE_DIR}/src/include/nanobench.h" DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
