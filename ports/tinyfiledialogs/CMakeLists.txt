cmake_minimum_required(VERSION 3.4)
project(tinyfiledialogs)

set(HEADERS "tinyfiledialogs.h")

set(SOURCES "tinyfiledialogs.c")

option(BUILD_SHARED_LIBS "Build shared libs" OFF)

set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

add_library(tinyfiledialogs ${SOURCES})

install(
    TARGETS tinyfiledialogs
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

install(FILES ${HEADERS} DESTINATION include)
