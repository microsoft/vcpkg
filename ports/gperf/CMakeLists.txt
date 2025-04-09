cmake_minimum_required(VERSION 3.5)
project(gperf LANGUAGES C CXX)

include(CheckCXXSourceCompiles)
include(GNUInstallDirs)

CHECK_CXX_SOURCE_COMPILES("int main(int n) { int dynamic_array[n]; }" HAVE_DYNAMIC_ARRAY)

set(LIBGP_SOURCES
	lib/getline.cc
	lib/getline.h
	lib/getopt.c
	lib/getopt.h
	lib/getopt1.c
	lib/hash.cc
	lib/hash.h)
add_library(gp STATIC ${LIBGP_SOURCES})
target_include_directories(gp PUBLIC "${CMAKE_SOURCE_DIR}/lib")

set(GPERF_SOURCES
	src/bool-array.cc
	src/bool-array.h
	src/bool-array.icc
	src/hash-table.cc
	src/hash-table.h
	src/input.cc
	src/input.h
	src/keyword-list.cc
	src/keyword-list.h
	src/keyword-list.icc
	src/keyword.cc
	src/keyword.h
	src/keyword.icc
	src/main.cc
	src/options.cc
	src/options.h
	src/options.icc
	src/output.cc
	src/output.h
	src/positions.cc
	src/positions.h
	src/positions.icc
	src/search.cc
	src/search.h
	src/version.cc
	src/version.h)
add_executable(gperf ${GPERF_SOURCES})
target_link_libraries(gperf gp)
target_include_directories(gperf PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")

configure_file(config.h.in config.h @ONLY)

install(TARGETS gperf RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
