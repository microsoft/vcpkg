cmake_minimum_required(VERSION 3.12)
project(pystring CXX)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

add_library(pystring pystring.cpp)
target_include_directories(
  pystring
  PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
)

include(GNUInstallDirs)

install(
  TARGETS pystring
  EXPORT pystring-config
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES pystring.h DESTINATION include/pystring)
endif()

install(
  EXPORT pystring-config
  NAMESPACE pystring::
  DESTINATION share/pystring
)
