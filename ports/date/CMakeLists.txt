cmake_minimum_required(VERSION 3.5.1)
project(tz CXX)

set(CMAKE_CXX_STANDARD 11)
if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

option(HAS_REMOTE_API "" 0)

add_definitions(-DNOMINMAX -DHAS_REMOTE_API=${HAS_REMOTE_API})

add_library(date INTERFACE)
target_include_directories(date INTERFACE $<INSTALL_INTERFACE:include>)

add_library(tz src/tz.cpp)
target_include_directories(tz PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include> $<INSTALL_INTERFACE:include>)

if(HAS_REMOTE_API)
  find_package(CURL REQUIRED)
  target_link_libraries(tz PUBLIC $<BUILD_INTERFACE:${CURL_LIBRARIES}>)
  target_include_directories(tz PUBLIC $<BUILD_INTERFACE:${CURL_INCLUDE_DIRS}>)
endif()

if(BUILD_SHARED_LIBS)
  target_compile_definitions(tz PRIVATE -DDATE_BUILD_DLL)
endif()

install(
  TARGETS tz date
  EXPORT tz
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/unofficial-date-config.cmake" "include(\${CMAKE_CURRENT_LIST_DIR}/unofficial-date-targets.cmake)\n")

install(EXPORT tz FILE unofficial-date-targets.cmake NAMESPACE unofficial::date:: DESTINATION share/unofficial-date)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/unofficial-date-config.cmake DESTINATION share/unofficial-date)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES include/date/date.h include/date/tz.h include/date/julian.h include/date/iso_week.h include/date/islamic.h  DESTINATION include/date)
endif()
