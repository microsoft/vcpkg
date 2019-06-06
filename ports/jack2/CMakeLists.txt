cmake_minimum_required(VERSION 3.8)
project(jack2 C)

include_directories(common)

add_library(jack2 STATIC common/JackWeakAPI.c)

install(TARGETS jack2
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(DIRECTORY common/jack DESTINATION include)
