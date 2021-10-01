cmake_minimum_required (VERSION 3.9)
project (alac_decoder)

set(HEADERS
  decomp.h
  demux.h
  stream.h
  wavwriter.h
)

set (SRCS
  decomp.c
  alac.c
  demux.c
  stream.c
  wavwriter.c
)

if(MSVC)
  add_compile_options(/W4 -D_CRT_SECURE_NO_WARNINGS -DTARGET_OS_WIN32)
else()
  add_compile_options(-Wno-error=implicit-function-declaration)
endif()

include_directories(.)

add_library(libalac_decoder ${SRCS})

add_executable(alac_decoder main.c)
target_link_libraries(alac_decoder libalac_decoder)

install(
  TARGETS libalac_decoder
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_TOOLS)
  install (
    TARGETS alac_decoder
    RUNTIME DESTINATION tools/alac-decoder
  )
endif()

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES ${HEADERS} DESTINATION include/alac_decoder)
endif()
