cmake_minimum_required(VERSION 3.21)

project(libtess2)

# Tesselator
add_library(libtess2 STATIC)

target_sources(libtess2 PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/Source/bucketalloc.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/Source/dict.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/Source/geom.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/Source/mesh.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/Source/priorityq.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/Source/sweep.c"
    "${CMAKE_CURRENT_SOURCE_DIR}/Source/tess.c")

target_include_directories(libtess2 PUBLIC
  "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Include>"
  "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/Source>"
)
set_target_properties(libtess2 PROPERTIES LINKER_LANGUAGE CXX)

install(TARGETS libtess2 EXPORT unofficial-libtess2-config)

install(
    FILES "${CMAKE_CURRENT_SOURCE_DIR}/Include/tesselator.h"
    TYPE INCLUDE
)

install(
    EXPORT unofficial-libtess2-config
    NAMESPACE unofficial::libtess2::
    DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/unofficial-libtess2"
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)
