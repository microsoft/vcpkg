cmake_minimum_required (VERSION 3.8)
project (hungarian C)

add_library(hungarian
  ${CMAKE_CURRENT_LIST_DIR}/libhungarian/hungarian.h
  ${CMAKE_CURRENT_LIST_DIR}/libhungarian/hungarian.c
)

target_include_directories(hungarian PUBLIC
  $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/libhungarian>
  $<INSTALL_INTERFACE:include>
)

set_target_properties(hungarian PROPERTIES PUBLIC_HEADER ${CMAKE_CURRENT_LIST_DIR}/libhungarian/hungarian.h)

install(
  TARGETS hungarian
  EXPORT hungarian
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
  PUBLIC_HEADER DESTINATION include
)

install(EXPORT hungarian
    DESTINATION "share/hungarian"
    FILE hungarianConfig.cmake
    NAMESPACE hungarian::
)
