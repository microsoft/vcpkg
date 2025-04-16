cmake_minimum_required(VERSION 3.23 FATAL_ERROR)

PROJECT(spimpl)

add_library (spimpl INTERFACE "spimpl.h")

install(TARGETS spimpl 
    EXPORT spimpl)

install(FILES "spimpl.h" DESTINATION include/spimpl)

install(EXPORT spimpl
  FILE unofficial-spimpl-targets.cmake
  NAMESPACE unofficial::spimpl::
  DESTINATION share/unofficial-spimpl
)


