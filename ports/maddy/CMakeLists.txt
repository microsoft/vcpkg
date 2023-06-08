cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(maddy LANGUAGES CXX)

include(GNUInstallDirs)

add_library(maddy INTERFACE)
target_include_directories(maddy INTERFACE $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>)

install(TARGETS maddy EXPORT unofficial-maddy)

install(
    EXPORT unofficial-maddy
    FILE unofficial-maddy-config.cmake
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/unofficial-maddy"
    NAMESPACE unofficial::maddy::
)

install(
    DIRECTORY "${CMAKE_SOURCE_DIR}/include/maddy"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)
