cmake_minimum_required (VERSION 3.9)
project (libaiff)
set(SRC
  iff.c aifx.c lpcm.c g711.c
  float32.c libaiff.c
  extended.c pascal.c
)

if(MSVC)
  add_compile_options(/W4 -D_CRT_SECURE_NO_WARNINGS -DHAVE_INTTYPES_H -DHAVE_STDINT_H  -DHAVE_STRING_H -DHAVE_STDLIB_H)
endif()

include_directories(.)

add_library(libaiff ${SRC})


install(
  TARGETS libaiff
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)


if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES libaiff/libaiff.h  libaiff/config.h  libaiff/endian.h DESTINATION include/libaiff)
endif()
