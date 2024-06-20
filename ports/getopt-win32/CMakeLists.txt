cmake_minimum_required(VERSION 3.14)

project(getopt-win32 C)

if(BUILD_SHARED_LIBS)
    add_definitions(-DEXPORTS_GETOPT)
else()
    add_definitions(-DSTATIC_GETOPT)
endif()

add_library(getopt getopt.c)

TARGET_INCLUDE_DIRECTORIES(getopt INTERFACE $<INSTALL_INTERFACE:include>)

install(
    TARGETS getopt
    EXPORT unofficial-getopt-win32
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    INCLUDES DESTINATION include
)

install(
    EXPORT unofficial-getopt-win32
    NAMESPACE unofficial::getopt-win32::
    DESTINATION share/unofficial-getopt-win32
    FILE unofficial-getopt-win32-config.cmake
)
