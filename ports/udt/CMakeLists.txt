cmake_minimum_required(VERSION 3.12 FATAL_ERROR)

project(udt LANGUAGES CXX)

include(GNUInstallDirs)

file(GLOB UDT_HEADERS "src/*.h")
file(GLOB UDT_SOURCES "src/*.cpp")

add_library(udt ${UDT_HEADERS} ${UDT_SOURCES})
if(WIN32)
    target_compile_definitions(udt PRIVATE -DWIN32)
    if(MSVC)
        target_compile_definitions(udt PRIVATE -DUDT_EXPORTS)
    endif()
    target_link_libraries(udt PRIVATE ws2_32)
elseif(UNIX AND NOT APPLE)
    target_compile_definitions(udt PRIVATE -DLINUX)
elseif(APPLE)
    target_compile_definitions(udt PRIVATE -DOSX)
endif()
target_include_directories(udt PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/src>"
    "$<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}/udt>")

install(TARGETS udt EXPORT unofficial-udt)

install(
    EXPORT unofficial-udt
    FILE unofficial-udt-config.cmake
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/unofficial-udt"
    NAMESPACE unofficial::udt::
)

install(FILES ${UDT_HEADERS} DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}/udt")
