cmake_minimum_required(VERSION 2.6)
project(SFML)

include_directories(include)
include_directories(src)

if(NOT BUILD_SHARED_LIBS)
    add_definitions(-DSFML_STATIC)
endif()
add_definitions(-DUNICODE -D_UNICODE)
add_definitions(-D_CRT_SECURE_NO_WARNINGS -D_SCL_SECURE_NO_WARNINGS)

# import SFML's 'sfml_add_library' macro and find_package utils

set(VERSION_MAJOR 2)
include(cmake/Config.cmake)
set(SFML_GENERATE_PDB ON)
include(cmake/Macros.cmake)
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/Modules/)

add_subdirectory(src/SFML/System)
add_subdirectory(src/SFML/Window)
add_subdirectory(src/SFML/Network)
add_subdirectory(src/SFML/Audio)
add_subdirectory(src/SFML/Graphics)

if(WIN32)
    set(LIB_SUFFIX /manual-link)
    add_subdirectory(src/SFML/Main)
    unset(LIB_SUFFIX)
endif()

if(NOT DEFINED SFML_SKIP_HEADERS)
    install(DIRECTORY include/ DESTINATION include)
endif()
