cmake_minimum_required(VERSION 3.8.0)
project(DeviceNameResolver CXX)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 /DUNICODE /D_UNICODE -D_SILENCE_STDEXT_HASH_DEPRECATION_WARNINGS -D_CRT_SECURE_NO_WARNINGS -DNOMINMAX)
endif()

include_directories(.)

file(GLOB DeviceNameResolver_srcs "*.cpp")

add_library(DeviceNameResolver ${DeviceNameResolver_srcs})

install(
  TARGETS DeviceNameResolver
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES DeviceNameResolver.h DESTINATION include)
endif()
