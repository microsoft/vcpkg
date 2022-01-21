cmake_minimum_required (VERSION 3.9)

project (udis86)

if (MSVC)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
endif()

set(
  lib_sources
  libudis86/decode.c
  libudis86/itab.c
  libudis86/syn-att.c
  libudis86/syn-intel.c
  libudis86/syn.c
  libudis86/udis86.c
)

set(lib_headers
  libudis86/decode.h
  libudis86/itab.h
  libudis86/extern.h
  libudis86/syn.h
  libudis86/types.h
  libudis86/udint.h
)

set(cli_srcs  udcli/udcli.c)

include_directories(.)

add_library(libudis86 ${lib_sources})

if(BUILD_SHARED_LIBS)
  target_compile_definitions(libudis86 PRIVATE -D_USRDLL)
endif()

add_executable(udcli ${cli_srcs})
target_link_libraries(udcli libudis86)


install(
  TARGETS libudis86
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_TOOLS)
  install (
    TARGETS udcli
    RUNTIME DESTINATION tools/libudis86
  )
endif()

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES ${lib_headers} DESTINATION include/libudis86)
  install(FILES udis86.h DESTINATION include)
endif()
