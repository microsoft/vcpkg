cmake_minimum_required(VERSION 3.5.1)
project(tz CXX)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

add_definitions(-DNOMINMAX)


include_directories("./include")

add_library(tz src/tz.cpp)

if(BUILD_SHARED_LIBS)
  target_compile_definitions(tz PRIVATE -DDATE_BUILD_DLL)
else()
  target_compile_definitions(tz PRIVATE -DDATE_BUILD_LIB)
endif()

install(
  TARGETS tz
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES include/date/date.h include/date/tz.h include/date/julian.h include/date/iso_week.h include/date/islamic.h  DESTINATION include/date)
endif()
