cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(nanobench LANGUAGES CXX)

include(GNUInstallDirs)

add_library(nanobench INTERFACE)
target_include_directories(nanobench INTERFACE $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)

install(TARGETS nanobench EXPORT nanobench)

install(
    EXPORT nanobench
    FILE nanobench-config.cmake
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/nanobench"
    NAMESPACE nanobench::
)

install(FILES "${CMAKE_SOURCE_DIR}/src/include/nanobench.h" DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}")
