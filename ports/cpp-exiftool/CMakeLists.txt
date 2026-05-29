cmake_minimum_required(VERSION 3.21)
project(cpp-exiftool LANGUAGES CXX)

file(GLOB src_files "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")
file(GLOB public_headers "${CMAKE_CURRENT_SOURCE_DIR}/inc/*.h")
add_library(cpp-exiftool ${src_files})
target_include_directories(cpp-exiftool
                           PUBLIC
                           "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/inc>"
                           "$<INSTALL_INTERFACE:include>")
set_target_properties(cpp-exiftool PROPERTIES PUBLIC_HEADER "${public_headers}")

install(TARGETS cpp-exiftool
        EXPORT cpp-exiftool-targets
        LIBRARY DESTINATION lib
        PUBLIC_HEADER DESTINATION include/cpp-exiftool)

install(EXPORT cpp-exiftool-targets
        FILE unofficial-cpp-exiftool-config.cmake
        DESTINATION share/unofficial-cpp-exiftool
        NAMESPACE unofficial::cpp-exiftool::)
