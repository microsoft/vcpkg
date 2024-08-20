cmake_minimum_required(VERSION 3.8.0)

project(libstemmer)

file(GLOB SNOWBALL_SOURCES
  src_c/*.c
  runtime/api.c
  runtime/utilities.c
  libstemmer/libstemmer.c
)

add_library(stemmer ${SNOWBALL_SOURCES})

install(
  TARGETS stemmer
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES include/libstemmer.h DESTINATION include)
endif()
