cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(udt LANGUAGES CXX)

include(GNUInstallDirs)

file(GLOB UDT_HEADERS "src/*.h")
file(GLOB UDT_SOURCES "src/*.cpp")

add_library(udt ${UDT_HEADERS} ${UDT_SOURCES})
add_library(udt::udt ALIAS udt)

if(WIN32)
    if(MSVC AND BUILD_DYNAMIC_LIBS)
        target_compile_definitions(udt PRIVATE UDT_EXPORTS)
    endif()
    target_compile_definitions(udt PRIVATE WIN32)
elseif(UNIX AND NOT APPLE)
    target_compile_definitions(udt PRIVATE LINUX)
elseif(APPLE)
    target_compile_definitions(udt PRIVATE OSX)
endif()

target_include_directories(udt PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/src>"
    "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/udt>")

install(TARGETS udt EXPORT unofficial-udt)

install(
    EXPORT unofficial-udt
    FILE unofficial-udt-config.cmake
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/udt"
    NAMESPACE unofficial::udt::
)

install(FILES ${UDT_HEADERS} DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/udt")
