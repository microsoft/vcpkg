cmake_minimum_required(VERSION 3.8.0)
project(lodepng)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

include_directories(".")

add_library(lodepng  lodepng.cpp lodepng_util.cpp)

# add_executable(pngdetail pngdetail.cpp)

# target_link_libraries(pngdetail lodepng)

install(
  TARGETS lodepng
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

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
