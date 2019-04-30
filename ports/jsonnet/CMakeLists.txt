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
  third_party/md5/md5.cpp
)

include_directories(third_party/md5 include cpp core stdlib)

add_library(jsonnet ${jsonnet_sources})
target_link_libraries(jsonnet)

add_library(jsonnet++ cpp/libjsonnet++.cpp)
target_link_libraries(jsonnet++ jsonnet)
 
add_executable(jsonnet-bin cmd/jsonnet.cpp)
target_link_libraries(jsonnet-bin jsonnet)
set_target_properties(jsonnet-bin PROPERTIES OUTPUT_NAME jsonnet)

install(
  TARGETS jsonnet jsonnet++
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)
if(NOT DISABLE_INSTALL_TOOLS)
  install (
    TARGETS jsonnet-bin
    RUNTIME DESTINATION tools/jsonnet
  )
endif()

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES include/libjsonnet++.h include/libjsonnet.h DESTINATION include)
endif()
