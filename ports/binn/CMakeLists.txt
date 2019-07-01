cmake_minimum_required(VERSION 3.8)

project(binn
  VERSION 1.0
  DESCRIPTION "Binn is a binary data serialization format designed to be compact, fast and easy to use."
  HOMEPAGE_URL "https://github.com/liteserver/binn"
)

add_library (binn src/binn.h src/binn.c)

target_include_directories(binn
    PUBLIC
    ${PROJECT_SOURCE_DIR}/src
)

install(
  TARGETS binn
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
