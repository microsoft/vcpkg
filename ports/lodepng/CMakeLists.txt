cmake_minimum_required(VERSION 3.8.0)
project(lodepng)

add_library(lodepng  lodepng.cpp lodepng_util.cpp)
target_include_directories(lodepng PUBLIC
  $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

# add_executable(pngdetail pngdetail.cpp)

# target_link_libraries(pngdetail lodepng)

file(WRITE "${CMAKE_BINARY_DIR}/lodepng-config.cmake" "include(\"\${CMAKE_CURRENT_LIST_DIR}/lodepng-targets.cmake\")")
install(FILES "${CMAKE_BINARY_DIR}/lodepng-config.cmake" DESTINATION "share/lodepng/")

install(TARGETS lodepng EXPORT lodepng-targets)

install(EXPORT lodepng-targets DESTINATION share/lodepng/)

# if(NOT DISABLE_INSTALL_TOOLS)
#   install (
#     TARGETS pngdetail
#     RUNTIME DESTINATION tools/lodepng
#   )
# endif()

if(NOT DDISABLE_INSTALL_EXAMPLES)
  install(DIRECTORY examples  DESTINATION share/lodepng/)
endif()

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES lodepng.h lodepng_util.h  DESTINATION include)
endif()
