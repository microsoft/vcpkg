cmake_minimum_required(VERSION 3.12)

project(glad C)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")

include(GladConfig)

glad_add_library(glad API "${GLAD_API}")

set_target_properties(glad PROPERTIES 
	INCLUDE_DIRECTORIES ""
	INTERFACE_INCLUDE_DIRECTORIES "")

target_include_directories(glad PUBLIC
	$<BUILD_INTERFACE:${CMAKE_CURRENT_BINARY_DIR}/gladsources/glad/include>
	$<INSTALL_INTERFACE:include>)

install(TARGETS glad EXPORT GladTargets)
install(EXPORT GladTargets DESTINATION "share/glad")
install(DIRECTORY "${CMAKE_BINARY_DIR}/gladsources/glad/include/" TYPE INCLUDE)
