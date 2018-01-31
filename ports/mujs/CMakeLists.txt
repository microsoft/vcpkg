cmake_minimum_required(VERSION 3.9)
project(mujs)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

file(GLOB libmujs_sources js*.c utf*.c regexp.c)

include_directories(.)


add_library(libmujs ${libmujs_sources})

install(
  TARGETS libmujs
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES mujs.h DESTINATION include)
endif()
