cmake_minimum_required(VERSION 3.14)

add_custom_target(LIBS)

find_package(XercesC CONFIG REQUIRED)
add_library(xerces-c INTERFACE IMPORTED GLOBAL)
target_link_libraries(xerces-c INTERFACE XercesC::XercesC)

find_package(ZLIB REQUIRED)

add_library(zlib INTERFACE IMPORTED GLOBAL)
add_library(zlibstatic INTERFACE IMPORTED GLOBAL)

target_link_libraries(zlib INTERFACE ZLIB::ZLIB)
target_link_libraries(zlibstatic INTERFACE ZLIB::ZLIB)
