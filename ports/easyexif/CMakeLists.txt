cmake_minimum_required(VERSION 3.11)
project(easyexif CXX)
include(GNUInstallDirs)

add_library(easyexif
    exif.h
    exif.cpp
)

set_target_properties(easyexif
PROPERTIES
    CXX_STANDARD 11
    PUBLIC_HEADER exif.h
)

install(TARGETS easyexif
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
)
