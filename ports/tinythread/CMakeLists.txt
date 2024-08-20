cmake_minimum_required(VERSION 3.8.0)

project(tinythread)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

include_directories(source)

add_library(tinythread source/tinythread.cpp)

install(
  TARGETS tinythread
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES  source/tinythread.h source/fast_mutex.h DESTINATION include)
endif()
