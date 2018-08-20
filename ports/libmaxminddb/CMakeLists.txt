cmake_minimum_required (VERSION 3.9)
project (libmaxminddb)

if(MSVC)
  add_compile_options(/W4 -D_CRT_SECURE_NO_WARNINGS)
endif()


set (SRCS
src/maxminddb.c
src/data-pool.c
)


include_directories(. src include projects/VS12)

if(BUILD_SHARED_LIBS)
  set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()


add_library(libmaxminddb ${SRCS})

if(WIN32)
  target_link_libraries(libmaxminddb ws2_32)
endif()



install(
  TARGETS libmaxminddb
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES include/maxminddb.h projects/VS12/maxminddb_config.h DESTINATION include/maxminddb)
endif()