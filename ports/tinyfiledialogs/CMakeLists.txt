cmake_minimum_required(VERSION 3.4)
project(tinyfiledialogs C)

add_library(tinyfiledialogs tinyfiledialogs.c)

install(
    TARGETS tinyfiledialogs
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)
