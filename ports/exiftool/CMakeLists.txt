cmake_minimum_required(VERSION 3.20)
project(exiftool LANGUAGES CXX)

file(GLOB src_files "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")
file(GLOB public_headers "${CMAKE_CURRENT_SOURCE_DIR}/inc/*.h")
add_library(exiftool "${src_files}")
target_include_directories(exiftool
                           PUBLIC
                           $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/inc>
                           $<INSTALL_INTERFACE:include/exiftool>)
set_target_properties(exiftool PROPERTIES PUBLIC_HEADER "${public_headers}")
install(TARGETS exiftool
        EXPORT exiftool-targets
        LIBRARY DESTINATION lib
        PUBLIC_HEADER DESTINATION include/exiftool)
install(EXPORT exiftool-targets
        DESTINATION share/exiftool
        NAMESPACE exiftool::)

include(CMakePackageConfigHelpers)
configure_package_config_file(
  "${CMAKE_CURRENT_SOURCE_DIR}/exiftool-config.cmake.in"
  "${CMAKE_CURRENT_BINARY_DIR}/exiftool-config.cmake"
  INSTALL_DESTINATION "share/exiftool"
)
install(
  FILES "${CMAKE_CURRENT_BINARY_DIR}/exiftool-config.cmake"
  DESTINATION "share/exiftool"
)
