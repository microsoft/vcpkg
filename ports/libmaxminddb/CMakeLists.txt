cmake_minimum_required (VERSION 3.9)
project(maxminddb C)

set(CMAKE_DEBUG_POSTFIX d)
set(CMAKE_SHARED_LIBRARY_PREFIX lib)
set(CMAKE_STATIC_LIBRARY_PREFIX lib)

if(MSVC)
  add_compile_options(-D_CRT_SECURE_NO_WARNINGS)
endif()

set(SRCS
  src/maxminddb.c
  src/data-pool.c
)

include_directories(. src include projects/VS12)

add_library(maxminddb ${SRCS})

if(WIN32)
  target_link_libraries(maxminddb ws2_32)
endif()

install(
  TARGETS maxminddb
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES include/maxminddb.h projects/VS12/maxminddb_config.h DESTINATION include/maxminddb)
endif()
