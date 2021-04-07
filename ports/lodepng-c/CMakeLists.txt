cmake_minimum_required(VERSION 3.8.0)
project(lodepng-c C)

configure_file(${CMAKE_CURRENT_LIST_DIR}/lodepng.cpp ${CMAKE_CURRENT_LIST_DIR}/lodepng.c COPYONLY)
add_library(lodepng-c lodepng.c)
target_include_directories(lodepng-c PUBLIC
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

file(WRITE "${CMAKE_BINARY_DIR}/lodepng-c-config.cmake" "include(\"\${CMAKE_CURRENT_LIST_DIR}/lodepng-c-targets.cmake\")")
install(FILES "${CMAKE_BINARY_DIR}/lodepng-c-config.cmake" DESTINATION "share/lodepng-c/")

install(TARGETS lodepng-c EXPORT lodepng-c-targets)

install(EXPORT lodepng-c-targets DESTINATION share/lodepng-c/)

if(NOT DDISABLE_INSTALL_EXAMPLES)
  install(DIRECTORY examples  DESTINATION share/lodepng-c/)
endif()

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES lodepng.h DESTINATION include)
endif()
