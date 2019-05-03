cmake_minimum_required(VERSION 3.8)
project(minitrace C)

set(minitrace_HEADERS minitrace.h)
set(minitrace_SOURCES minitrace.c)

add_library(minitrace ${minitrace_SOURCES})

# Install headers
install(FILES ${minitrace_HEADERS} DESTINATION include/minitrace)

# Install minitrace
install(
	TARGETS minitrace EXPORT minitraceConfig
	RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
	LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
	ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
)

# Export config file for minitrace
export(
	TARGETS minitrace
	NAMESPACE minitrace::
	FILE "${CMAKE_CURRENT_BINARY_DIR}/minitrace-config.cmake"
)

# Install config file
install(
	EXPORT minitraceConfig
	DESTINATION "${CMAKE_INSTALL_PREFIX}/share/minitrace"
	NAMESPACE minitrace::
)
