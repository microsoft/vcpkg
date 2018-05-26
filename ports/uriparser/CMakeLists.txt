cmake_minimum_required(VERSION 3.8)
project(uriparser C)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

include_directories(include)

file(GLOB SRC src/*.c)

set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)

add_library(uriparser ${SRC})

install(
  TARGETS uriparser
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(DIRECTORY include/ DESTINATION include)
endif()
