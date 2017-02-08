cmake_minimum_required (VERSION 3.4)
project (http-parser)

if (BUILD_SHARED_LIBS)
  SET(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

if(CMAKE_BUILD_TYPE MATCHES "Release")
  add_definitions(-DHTTP_PARSER_STRICT=0)
endif()

add_library(http_parser http_parser.c http_parser.h)

install(TARGETS http_parser
  RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}/bin"
  ARCHIVE DESTINATION "${CMAKE_INSTALL_PREFIX}/lib"
)

if (NOT SKIP_INSTALL_HEADERS)
  install(FILES http_parser.h DESTINATION "${CMAKE_INSTALL_PREFIX}/include")
endif()