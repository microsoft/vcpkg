cmake_minimum_required(VERSION 2.6)
project(SFML)

include_directories(${PROJECT_SOURCE_DIR}/include)
include_directories(${PROJECT_SOURCE_DIR}/src)

if(NOT BUILD_SHARED_LIBS)
    add_definitions(-DSFML_STATIC)
endif()
add_definitions(-DUNICODE -D_UNICODE)
add_definitions(-D_CRT_SECURE_NO_WARNINGS -D_SCL_SECURE_NO_WARNINGS)

# import SFML's 'sfml_add_library' macro and find_package utils

set(VERSION_MAJOR 2)
set(SFML_OS_WINDOWS ON)
set(SFML_GENERATE_PDB ON)
include(cmake/macros.cmake)
set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/cmake/Modules/)

# system module

file(GLOB SFML_SYSTEM_SOURCES
    ${PROJECT_SOURCE_DIR}/src/SFML/System/*.cpp
    ${PROJECT_SOURCE_DIR}/src/SFML/System/Win32/*cpp)

sfml_add_library(sfml-system
    SOURCES ${SFML_SYSTEM_SOURCES}
    EXTERNAL_LIBS winmm)

# window module

file(GLOB SFML_WINDOW_SOURCES
    ${PROJECT_SOURCE_DIR}/src/SFML/Window/*.cpp
    ${PROJECT_SOURCE_DIR}/src/SFML/Window/Win32/*cpp)

list(REMOVE_ITEM SFML_WINDOW_SOURCES
    ${PROJECT_SOURCE_DIR}/src/SFML/Window/EGLCheck.cpp
    ${PROJECT_SOURCE_DIR}/src/SFML/Window/EglContext.cpp)

sfml_add_library(sfml-window
    SOURCES ${SFML_WINDOW_SOURCES}
    DEPENDS sfml-system
    EXTERNAL_LIBS winmm gdi32 opengl32)

# network module

file(GLOB SFML_NETWORK_SOURCES
    ${PROJECT_SOURCE_DIR}/src/SFML/Network/*.cpp
    ${PROJECT_SOURCE_DIR}/src/SFML/Network/Win32/*cpp)

sfml_add_library(sfml-network
    SOURCES ${SFML_NETWORK_SOURCES}
    DEPENDS sfml-system
    EXTERNAL_LIBS ws2_32)

# audio module

file(GLOB SFML_AUDIO_SOURCES
    ${PROJECT_SOURCE_DIR}/src/SFML/Audio/*.cpp)

find_package(OpenAL REQUIRED)
find_package(Vorbis REQUIRED)
find_package(FLAC REQUIRED)

sfml_add_library(sfml-audio
    SOURCES ${SFML_AUDIO_SOURCES}
    DEPENDS sfml-system
    EXTERNAL_LIBS ${OPENAL_LIBRARY} ${VORBIS_LIBRARIES} ${FLAC_LIBRARY})

target_include_directories(sfml-audio SYSTEM PRIVATE ${OPENAL_INCLUDE_DIR})
target_include_directories(sfml-audio SYSTEM PRIVATE ${VORBIS_INCLUDE_DIRS})
target_include_directories(sfml-audio SYSTEM PRIVATE ${FLAC_INCLUDE_DIR})

# graphics module

file(GLOB SFML_GRAPHICS_SOURCES
    ${PROJECT_SOURCE_DIR}/src/SFML/Graphics/*.cpp)

find_package(JPEG REQUIRED)
find_package(Freetype REQUIRED) # fails to find debug lib
if(CMAKE_BUILD_TYPE MATCHES Debug)
    find_library(FREETYPE_DEBUG_LIBRARY freetyped)
    set(FREETYPE_ACTUAL_LIBRARY ${FREETYPE_DEBUG_LIBRARY})
else()
    set(FREETYPE_ACTUAL_LIBRARY ${FREETYPE_LIBRARY})
endif()
find_path(STB_HEADERS stb_image.h)

sfml_add_library(sfml-graphics
    SOURCES ${SFML_GRAPHICS_SOURCES}
    DEPENDS sfml-system sfml-window
    EXTERNAL_LIBS ${FREETYPE_ACTUAL_LIBRARY} ${JPEG_LIBRARY} opengl32)

target_include_directories(sfml-graphics SYSTEM PRIVATE ${STB_HEADERS})
target_include_directories(sfml-graphics SYSTEM PRIVATE ${FREETYPE_INCLUDE_DIRS})
target_include_directories(sfml-graphics SYSTEM PRIVATE ${JPEG_INCLUDE_DIR})
set_target_properties(sfml-graphics PROPERTIES COMPILE_FLAGS -DSTBI_FAILURE_USERMSG)

# main module

add_library(sfml-main STATIC ${PROJECT_SOURCE_DIR}/src/SFML/Main/MainWin32.cpp)
set_target_properties(sfml-main PROPERTIES DEBUG_POSTFIX -d)
install(TARGETS sfml-main ARCHIVE DESTINATION lib)

# headers

if(NOT DEFINED SFML_SKIP_HEADERS)
    install(DIRECTORY ${PROJECT_SOURCE_DIR}/include/ DESTINATION include)
endif()

# log linked libraries

message(STATUS "Link-time dependencies:")
message(STATUS "  " ${VORBIS_LIBRARY})
message(STATUS "  " ${VORBISFILE_LIBRARY})
message(STATUS "  " ${VORBISENC_LIBRARY})
message(STATUS "  " ${OGG_LIBRARY})
message(STATUS "  " ${OPENAL_LIBRARY})
message(STATUS "  " ${FLAC_LIBRARY})
message(STATUS "  " ${FREETYPE_ACTUAL_LIBRARY})
message(STATUS "  " ${JPEG_LIBRARY})
