cmake_minimum_required(VERSION 3.14)

project(getopt-win32 C)

if(BUILD_SHARED_LIBS)
    add_definitions(-DEXPORTS_GETOPT)
else()
    add_definitions(-DSTATIC_GETOPT)
endif()
add_library(getopt getopt.c)
install(TARGETS getopt)
