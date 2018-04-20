cmake_minimum_required (VERSION 3.4)

include(cmake/target.cmake)

project (http-parser)

if (BUILD_SHARED_LIBS)
  SET(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS ON)
endif()

if(CMAKE_BUILD_TYPE MATCHES "Release")
  add_definitions(-DHTTP_PARSER_STRICT=0)
endif()

set(NODEJS_HTTP_PARSER_LIB http_parser)
add_library(${NODEJS_HTTP_PARSER_LIB} http_parser.c http_parser.h)

target_include_directories(${NODEJS_HTTP_PARSER_LIB} PUBLIC
	$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
	$<INSTALL_INTERFACE:include>)

# A safer name to use as with TARGET_LINK_LIBRARIES
add_library(nodejs::http_parser ALIAS ${NODEJS_HTTP_PARSER_LIB})

IF (NODEJS_HTTP_PARSER_INSTALL)
	include(GNUInstallDirs)
	include(CMakePackageConfigHelpers)

	set(NODEJS_HTTP_PARSER_CMAKE_DIR ${CMAKE_INSTALL_LIBDIR}/cmake/http-parser CACHE STRING
		"Installation directory for cmake files, relative to ${CMAKE_INSTALL_PREFIX}.")
	set(NODEJS_HTTP_PARSER_VERSION_CONFIG ${PROJECT_BINARY_DIR}/http-parser-config-version.cmake)
	set(NODEJS_HTTP_PARSER_PROJECT_CONFIG ${PROJECT_BINARY_DIR}/http-parser-config.cmake)

	set(NODEJS_HTTP_PARSER_LIB_DIR ${CMAKE_INSTALL_LIBDIR} CACHE STRING
		"Installation directory for libraries, relative to ${CMAKE_INSTALL_PREFIX}.")

	set(NODEJS_HTTP_PARSER_INC_DIR ${CMAKE_INSTALL_INCLUDEDIR} CACHE STRING
		"Installation directory for include files, relative to ${CMAKE_INSTALL_PREFIX}.")

	# Generate the version, config and target files into the build directory.
	write_basic_package_version_file(
		${NODEJS_HTTP_PARSER_VERSION_CONFIG}
		VERSION ${NODEJS_HTTP_PARSER_VERSION}
		COMPATIBILITY ExactVersion )

	configure_package_config_file(
		"cmake/http-parser-config.cmake.in"
		${NODEJS_HTTP_PARSER_PROJECT_CONFIG}
		INSTALL_DESTINATION ${NODEJS_HTTP_PARSER_CMAKE_DIR}
		PATH_VARS NODEJS_HTTP_PARSER_VERSION)

	# Install version, config and target files.
	install(
		FILES ${NODEJS_HTTP_PARSER_PROJECT_CONFIG} ${NODEJS_HTTP_PARSER_VERSION_CONFIG}
		DESTINATION ${NODEJS_HTTP_PARSER_CMAKE_DIR})

	SET( NODEJS_HTTP_PARSER_INSTALL_TARGETS ${NODEJS_HTTP_PARSER_LIB})

	install(
		TARGETS ${NODEJS_HTTP_PARSER_INSTALL_TARGETS}
		EXPORT NODEJS_HTTP_PARSER_ALL_TARGETS
		LIBRARY DESTINATION lib
		ARCHIVE DESTINATION lib
		RUNTIME DESTINATION bin
	)

	install(
		EXPORT NODEJS_HTTP_PARSER_ALL_TARGETS
		NAMESPACE nodejs::
		FILE http-parser-targets.cmake
		DESTINATION ${NODEJS_HTTP_PARSER_CMAKE_DIR} )

	install( FILES http_parser.h DESTINATION ${NODEJS_HTTP_PARSER_INC_DIR} )
ENDIF ()