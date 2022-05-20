cmake_minimum_required(VERSION 3.16)
project(Nuklear LANGUAGES C)

option(INSTALL_EXAMPLE "Install the example code" OFF)
option(INSTALL_DEMO "Install the demo code" OFF)

add_library(nuklear INTERFACE)

include(GNUInstallDirs)
target_include_directories(nuklear INTERFACE "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/nuklear>")
target_compile_definitions(nuklear INTERFACE NK_IMPLEMENTATION)

# Installation
install(
    TARGETS nuklear
    EXPORT unofficial-nuklear
    ARCHIVE DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    LIBRARY DESTINATION "${CMAKE_INSTALL_LIBDIR}"
    RUNTIME DESTINATION "${CMAKE_INSTALL_BINDIR}"
)

install(FILES "${CMAKE_CURRENT_LIST_DIR}/nuklear.h"
        DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/nuklear")


install(EXPORT unofficial-nuklear
        FILE "unofficial-nuklear-config.cmake"
        DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/unofficial-nuklear")

if (INSTALL_EXAMPLE)
    install(DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/example"
            DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/nuklear")
endif()

if (INSTALL_DEMO)
    install(DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/demo"
            DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/nuklear")
endif()
