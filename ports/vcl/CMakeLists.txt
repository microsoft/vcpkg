cmake_minimum_required(VERSION 3.12)

project(vcl)

option(VCL_BUILD_EXAMPLE "Build example for vcl" OFF)

file(GLOB HEADER_FILES ${CMAKE_CURRENT_SOURCE_DIR}/*.h)

include_directories("${CMAKE_CURRENT_SOURCE_DIR}/*.h")

if(VCL_BUILD_EXAMPLE)
    install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/dispatch_example.cpp DESTINATION example)
endif()

install(FILES ${HEADER_FILES} DESTINATION include/vcl)