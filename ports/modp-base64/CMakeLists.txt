cmake_minimum_required(VERSION 3.8)
project(libmodpbase64 C)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

configure_file(config.h.cmake config.h @ONLY)

include_directories(. ${SOURCE_PATH}/src ${CMAKE_CURRENT_BINARY_DIR})

add_library(libmodpbase64 ${SOURCE_PATH}/src/modp_b64.c libmodpbase64.def)

install(
  TARGETS libmodpbase64
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(
    FILES ${SOURCE_PATH}/src/modp_b64.h
    DESTINATION include
  )
endif()
