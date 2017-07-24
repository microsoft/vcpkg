cmake_minimum_required(VERSION 3.8)
project(uriparser C CXX)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

include_directories(include)

set(SRC
  src/UriCommon.c
  src/UriCommon.h
  src/UriCompare.c
  src/UriEscape.c
  src/UriFile.c
  src/UriIp4.c
  src/UriIp4Base.c
  src/UriIp4Base.h
  src/UriNormalize.c
  src/UriNormalizeBase.c
  src/UriNormalizeBase.h
  src/UriParse.c
  src/UriParseBase.c
  src/UriParseBase.h
  src/UriQuery.c
  src/UriRecompose.c
  src/UriResolve.c
  src/UriShorten.c
)

if(BUILD_SHARED_LIBS)
  set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

add_library(uriparser ${SRC})

install(
  TARGETS uriparser
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)


if(NOT DISABLE_INSTALL_HEADERS)
  install(DIRECTORY include/ DESTINATION include)
endif()
