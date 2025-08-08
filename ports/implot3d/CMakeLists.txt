cmake_minimum_required(VERSION 3.8)
project(implot3d CXX)

set(CMAKE_DEBUG_POSTFIX d)

add_library(${PROJECT_NAME} ""
		${CMAKE_CURRENT_SOURCE_DIR}/implot3d.cpp
		${CMAKE_CURRENT_SOURCE_DIR}/implot3d_items.cpp
		${CMAKE_CURRENT_SOURCE_DIR}/implot3d_demo.cpp
		${CMAKE_CURRENT_SOURCE_DIR}/implot3d_meshes.cpp
)
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_11)

find_package(imgui CONFIG REQUIRED)
target_link_libraries(${PROJECT_NAME} PUBLIC imgui::imgui)

target_include_directories(
	${PROJECT_NAME}
	PUBLIC
	   	$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
		$<INSTALL_INTERFACE:include>
)

install(
	TARGETS ${PROJECT_NAME}
	EXPORT ${PROJECT_NAME}_target
	ARCHIVE DESTINATION lib
	LIBRARY DESTINATION lib
	RUNTIME DESTINATION bin
)

install(FILES
	${CMAKE_CURRENT_SOURCE_DIR}/implot3d.h
	${CMAKE_CURRENT_SOURCE_DIR}/implot3d_internal.h
	DESTINATION include
)

install(
	EXPORT ${PROJECT_NAME}_target
	NAMESPACE ${PROJECT_NAME}::
	FILE ${PROJECT_NAME}-config.cmake
	DESTINATION share/${PROJECT_NAME}
)
