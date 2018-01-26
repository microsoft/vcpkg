cmake_minimum_required(VERSION 3.10)

project(Unicorn_Lib LANGUAGES CXX DESCRIPTION "Unicode library for C++ by Ross Smith")
set(CMAKE_CXX_STANDARD 17)
option(UNICORN_LIB_SKIP_HEADERS "If the headers installation is skipped or not." OFF)

find_path(RS_CORE_LIB_INCLUDE_DIR rs-core/common.hpp)
#find_library(RW_UTILITIES_LIBRARY NAMES rw_utilities)

file(GLOB_RECURSE UNICORN_LIB_SOURCES ${PROJECT_SOURCE_DIR}/unicorn/*.cpp)
foreach(ITR ${UNICORN_LIB_SOURCES})
	if(ITR MATCHES "(.*)-test.cpp(.*)")
		list(REMOVE_ITEM UNICORN_LIB_SOURCES ${ITR})
	endif()
endforeach()
add_library(unicorn-lib ${UNICORN_LIB_SOURCES})
target_include_directories(
	unicorn-lib
	PUBLIC ${PROJECT_SOURCE_DIR}
	PUBLIC ${RS_CORE_LIB_INCLUDE_DIR}
)
target_compile_definitions(
	unicorn-lib
	PRIVATE -DUNICODE -D_UNICODE _CRT_SECURE_NO_WARNINGS
)

if(NOT UNICORN_LIB_SKIP_HEADERS)
	install(DIRECTORY ${PROJECT_SOURCE_DIR}/unicorn DESTINATION include FILES_MATCHING PATTERN "*.hpp")
endif()
install(TARGETS unicorn-lib DESTINATION lib)