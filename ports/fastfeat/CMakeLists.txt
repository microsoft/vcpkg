cmake_minimum_required(VERSION 3.8)
project(fastfeat)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

include_directories(.)
file( GLOB SRCS *.c *.def)
add_library(fastfeat ${SRCS})


install(
  TARGETS fastfeat
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(
    FILES fast.h DESTINATION include
  )
endif()
