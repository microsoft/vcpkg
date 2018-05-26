cmake_minimum_required(VERSION 3.5.1)
project(jsonnet)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

if(BUILD_SHARED_LIBS)
  set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

set( jsonnet_sources
  core/desugarer.cpp
  core/formatter.cpp
  core/lexer.cpp
  core/libjsonnet.cpp
  core/parser.cpp
  core/pass.cpp
  core/static_analysis.cpp
  core/string_utils.cpp
  core/vm.cpp
)

include_directories(third_party/md5 include cpp core stdlib)

add_library(md5 STATIC third_party/md5/md5.cpp)

add_library(libjsonnet ${jsonnet_sources})
target_link_libraries(libjsonnet md5)

add_library(libjsonnet++ cpp/libjsonnet++.cpp)
target_link_libraries(libjsonnet++ libjsonnet)

add_executable(jsonnet cmd/jsonnet.cpp)
target_link_libraries(jsonnet libjsonnet)


install(
  TARGETS libjsonnet libjsonnet++
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
if(NOT DISABLE_INSTALL_TOOLS)
  install (
    TARGETS jsonnet
    RUNTIME DESTINATION tools/jsonnet
  )
endif()

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES include/libjsonnet++.h include/libjsonnet.h DESTINATION include)
endif()
