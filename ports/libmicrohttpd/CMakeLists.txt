cmake_minimum_required(VERSION 3.8)
project(libmicrohttpd C)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

set(MIN_SRC contrib/libmicrohttpd)


set(SRC
  src/microhttpd/base64.c
  src/microhttpd/basicauth.c
  src/microhttpd/connection.c
  src/microhttpd/daemon.c
  src/microhttpd/digestauth.c
  src/microhttpd/internal.c
  src/microhttpd/md5.c
  src/microhttpd/memorypool.c
  src/microhttpd/mhd_mono_clock.c
  src/microhttpd/postprocessor.c
  src/microhttpd/reason_phrase.c
  src/microhttpd/response.c
  src/microhttpd/tsearch.c
  src/microhttpd/sysfdsetsize.c
  src/microhttpd/mhd_str.c
  src/microhttpd/mhd_threads.c
  src/microhttpd/mhd_sockets.c
  src/microhttpd/mhd_itc.c
  src/microhttpd/mhd_compat.c
)
set(HEADERS
  src/microhttpd/base64.h
  src/microhttpd/connection.h
  src/microhttpd/internal.h
  src/microhttpd/md5.h
  src/microhttpd/memorypool.h
  src/microhttpd/mhd_byteorder.h
  src/microhttpd/mhd_limits.h
  src/microhttpd/mhd_mono_clock.h
  src/microhttpd/response.h
  src/microhttpd/tsearch.h
  src/microhttpd/sysfdsetsize.h
  src/microhttpd/mhd_str.h
  src/microhttpd/mhd_threads.h
  src/microhttpd/mhd_locks.h
  src/microhttpd/mhd_sockets.h
  src/microhttpd/mhd_itc.h
  src/microhttpd/mhd_itc_types.h
  src/microhttpd/mhd_compat.h
)

include_directories(${HEADERS} src/include w32/common)

add_library(libmicrohttpd ${SRC})

if(BUILD_SHARED_LIBS)
  target_compile_definitions(libmicrohttpd PRIVATE -DMHD_W32DLL)
else()
  target_compile_definitions(libmicrohttpd PRIVATE -DMHD_W32LIB)
endif()

 target_link_libraries(libmicrohttpd ws2_32)

install(
  TARGETS libmicrohttpd
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES   src/include/microhttpd.h DESTINATION include)
endif()
