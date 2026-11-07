cmake_minimum_required(VERSION 3.8)
project(implot CXX)

find_package(imgui CONFIG REQUIRED)

set(CMAKE_DEBUG_POSTFIX d)

add_library(${PROJECT_NAME} "")
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})
target_compile_features(${PROJECT_NAME} PUBLIC cxx_std_11)
target_link_libraries(${PROJECT_NAME} PUBLIC imgui::imgui)
target_include_directories(
	${PROJECT_NAME}
	PUBLIC
	   	$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
		$<INSTALL_INTERFACE:include>
)

target_sources(
	${PROJECT_NAME}
	PRIVATE
		${CMAKE_CURRENT_SOURCE_DIR}/implot.cpp
		${CMAKE_CURRENT_SOURCE_DIR}/implot_items.cpp
		${CMAKE_CURRENT_SOURCE_DIR}/implot_demo.cpp
)

install(
	TARGETS ${PROJECT_NAME}
	EXPORT ${PROJECT_NAME}_target
	ARCHIVE DESTINATION lib
	LIBRARY DESTINATION lib
	RUNTIME DESTINATION bin
)

if(NOT IMPLOT_SKIP_HEADERS)
    install(FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/implot.h
		${CMAKE_CURRENT_SOURCE_DIR}/implot_internal.h
        DESTINATION include
    )
endif()

install(
	EXPORT ${PROJECT_NAME}_target
	NAMESPACE ${PROJECT_NAME}::
	FILE ${PROJECT_NAME}-targets.cmake
	DESTINATION share/${PROJECT_NAME}
)

install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/implot-config.cmake"
    DESTINATION share/${PROJECT_NAME}
)
