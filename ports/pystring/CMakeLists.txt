cmake_minimum_required(VERSION 3.5.1)
project(pystring C CXX)

if(MSVC)
  add_compile_options(/W3 /wd4005 /wd4996 /wd4018 -D_CRT_SECURE_NO_WARNINGS)
endif()

add_library(${PROJECT_NAME} "")
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
target_include_directories(
	${PROJECT_NAME}
	PUBLIC
		$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
		$<INSTALL_INTERFACE:include>
)

target_sources(
	${PROJECT_NAME}
	PRIVATE
		${CMAKE_CURRENT_SOURCE_DIR}/pystring.cpp
)

install(
  TARGETS ${PROJECT_NAME}
	EXPORT ${PROJECT_NAME}_target
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if(NOT DISABLE_INSTALL_HEADERS)
  install(FILES pystring.h DESTINATION include/pystring)
endif()

install(
	EXPORT ${PROJECT_NAME}_target
	NAMESPACE ${PROJECT_NAME}::
	FILE ${PROJECT_NAME}-config.cmake
	DESTINATION share/${PROJECT_NAME}
)
