cmake_minimum_required(VERSION 3.5.1)
project(tz CXX)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

if(BUILD_SHARED_LIBS)
  set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

include_directories(${PROJECT_SRC_DIR})

add_library(tz tz.cpp)

install(
  TARGETS tz
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES date.h tz.h julian.h iso_week.h islamic.h  DESTINATION include)
endif()
