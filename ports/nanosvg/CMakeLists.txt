cmake_minimum_required(VERSION 3.11)
project(nanosvg C)

set(NANOSVG_HEADERS src/nanosvg.h src/nanosvgrast.h)
add_library(nanosvg INTERFACE ${NANOSVG_HEADERS})

set_target_properties(nanosvg PROPERTIES PUBLIC_HEADER "${NANOSVG_HEADERS}")

install(TARGETS nanosvg
  EXPORT nanosvgTargets
  PUBLIC_HEADER DESTINATION include)

install(EXPORT nanosvgTargets
  FILE nanosvgTargets.cmake
  NAMESPACE unofficial::
  DESTINATION share/nanosvg)

install(FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/nanosvgConfig.cmake
  DESTINATION share/nanosvg)
