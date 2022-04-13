cmake_minimum_required(VERSION 3.8.0)
project(lodepng)

add_library(lodepng lodepng.cpp)
target_include_directories(lodepng PUBLIC
  $<INSTALL_INTERFACE:include>
)

file(WRITE "${CMAKE_BINARY_DIR}/lodepng-config.cmake" "include(\"\${CMAKE_CURRENT_LIST_DIR}/lodepng-targets.cmake\")")
install(FILES "${CMAKE_BINARY_DIR}/lodepng-config.cmake" DESTINATION "share/lodepng/")

install(TARGETS lodepng EXPORT lodepng-targets)

install(EXPORT lodepng-targets DESTINATION share/lodepng/)

add_library(lodepng-c lodepng.c)
target_include_directories(lodepng-c PUBLIC
  $<INSTALL_INTERFACE:include>
)

file(WRITE "${CMAKE_BINARY_DIR}/lodepng-c-config.cmake" "include(\"\${CMAKE_CURRENT_LIST_DIR}/lodepng-c-targets.cmake\")")
install(FILES "${CMAKE_BINARY_DIR}/lodepng-c-config.cmake" DESTINATION "share/lodepng-c/")

install(TARGETS lodepng-c EXPORT lodepng-c-targets)

install(EXPORT lodepng-c-targets DESTINATION share/lodepng-c/)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES lodepng.h DESTINATION include)
endif()
