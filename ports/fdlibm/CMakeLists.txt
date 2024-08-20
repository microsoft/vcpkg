cmake_minimum_required(VERSION 3.8)
project(fdlibm C)

file(GLOB fdlibm_SOURCES "*.c")

include_directories(".")

if(WIN32)
set(fdlibm_SOURCES ${fdlibm_SOURCES} libm5.def)
endif()


add_library(fdlibm ${fdlibm_SOURCES})

install(
  TARGETS  fdlibm
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib/manual-link
  ARCHIVE DESTINATION lib/manual-link
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(
    FILES
    fdlibm.h
    DESTINATION include
  )
endif()
