cmake_minimum_required(VERSION 3.9)
project(libass C CXX)

configure_file (${CMAKE_CURRENT_SOURCE_DIR}/config.h.in config.h)

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR})

# This is Windows-specific. Other acceptable values on different platforms should be
#    macOS - CONFIG_CORETEXT
#    linux - CONFIG_FONTCONFIG
add_compile_definitions(CONFIG_DIRECTWRITE)

file (GLOB_RECURSE SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/libass/*.c)

list(FILTER SOURCES EXCLUDE REGEX ".*ass_coretext.c$")
list(FILTER SOURCES EXCLUDE REGEX ".*ass_fontconfig.c$")

find_package(Freetype REQUIRED)

find_path(FRIBIDI_INCLUDE_DIR
          NAMES fribidi.h
          PATH_SUFFIXES fribidi)

find_library(FRIBIDI_LIBRARY NAMES fribidi)

add_library(ass STATIC ${SOURCES})

target_include_directories(ass PRIVATE ${FRIBIDI_INCLUDE_DIR})

target_link_libraries(ass PRIVATE Freetype::Freetype)

install(TARGETS ass
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib)

