cmake_minimum_required(VERSION 3.11)
project(nanosvg NONE)

set(NANOSVG_HEADERS src/nanosvg.h src/nanosvgrast.h)
add_library(nanosvg INTERFACE)

set_target_properties(nanosvg PROPERTIES PUBLIC_HEADER "${NANOSVG_HEADERS}")

install(TARGETS nanosvg
  EXPORT nanosvgTargets
  PUBLIC_HEADER DESTINATION include)

install(EXPORT nanosvgTargets
  FILE unofficial-nanosvg-config.cmake
  NAMESPACE unofficial::nanosvg::
  DESTINATION share/unofficial-nanosvg)
