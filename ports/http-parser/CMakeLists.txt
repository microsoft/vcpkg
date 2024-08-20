cmake_minimum_required(VERSION 3.4)
project(http-parser C)

if(CMAKE_BUILD_TYPE MATCHES "Release")
  add_definitions(-DHTTP_PARSER_STRICT=0)
endif()

add_library(http_parser http_parser.c http_parser.h)

target_include_directories(http_parser PUBLIC $<INSTALL_INTERFACE:include>)

install(
	TARGETS http_parser
	EXPORT NODEJS_HTTP_PARSER_ALL_TARGETS
	LIBRARY DESTINATION lib
	ARCHIVE DESTINATION lib
	RUNTIME DESTINATION bin
)

install(
	EXPORT NODEJS_HTTP_PARSER_ALL_TARGETS
	NAMESPACE unofficial::http_parser::
	FILE unofficial-http-parser-config.cmake
	DESTINATION share/unofficial-http-parser
)

install(FILES http_parser.h DESTINATION include)
