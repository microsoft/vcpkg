cmake_minimum_required(VERSION 3.12.4)
project(pffft C)

add_library(pffft pffft.c)

if(MSVC)
    target_compile_definitions(pffft PRIVATE _USE_MATH_DEFINES)
endif()

target_include_directories(pffft PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> $<INSTALL_INTERFACE:include>)

install(
	TARGETS pffft
	EXPORT pffft-config
)

install(
	EXPORT pffft-config
	NAMESPACE pffft::
	DESTINATION share/pffft
)

if(NOT DISABLE_INSTALL_HEADERS)
    install(FILES pffft.h DESTINATION include/pffft)
endif()