cmake_minimum_required(VERSION 3.8)
project(imgui CXX)

set(CMAKE_DEBUG_POSTFIX d)

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
		${CMAKE_CURRENT_SOURCE_DIR}/imgui.cpp
		${CMAKE_CURRENT_SOURCE_DIR}/imgui_demo.cpp
		${CMAKE_CURRENT_SOURCE_DIR}/imgui_draw.cpp
		${CMAKE_CURRENT_SOURCE_DIR}/imgui_widgets.cpp
		${CMAKE_CURRENT_SOURCE_DIR}/misc/cpp/imgui_stdlib.cpp
)

if(IMGUI_FREETYPE)
	find_package(Freetype REQUIRED)

	target_include_directories(
		${PROJECT_NAME}
		PRIVATE
			${FREETYPE_INCLUDE_DIRS}
	)

	target_sources(
		${PROJECT_NAME}
		PRIVATE
			${CMAKE_CURRENT_SOURCE_DIR}/misc/freetype/imgui_freetype.cpp
	)
endif()

install(
	TARGETS ${PROJECT_NAME}
	EXPORT ${PROJECT_NAME}_target
	ARCHIVE DESTINATION lib
	LIBRARY DESTINATION lib
	RUNTIME DESTINATION bin
)

if(NOT IMGUI_SKIP_HEADERS)
    install(FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui.h
		${CMAKE_CURRENT_SOURCE_DIR}/imconfig.h
		${CMAKE_CURRENT_SOURCE_DIR}/imgui_internal.h
		${CMAKE_CURRENT_SOURCE_DIR}/imstb_textedit.h
        ${CMAKE_CURRENT_SOURCE_DIR}/misc/cpp/imgui_stdlib.h
        DESTINATION include
    )

	if(IMGUI_COPY_BINDINGS)
		file(GLOB IMGUI_BINDINGS ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_* )
		install(
			FILES ${IMGUI_BINDINGS}
			DESTINATION include/bindings
		)
	endif()

	if(IMGUI_FREETYPE)
		install(FILES
			${CMAKE_CURRENT_SOURCE_DIR}/misc/freetype/imgui_freetype.h
			DESTINATION include
		)
	endif()
endif()

install(
	EXPORT ${PROJECT_NAME}_target
	NAMESPACE ${PROJECT_NAME}::
	FILE ${PROJECT_NAME}-config.cmake
	DESTINATION share/${PROJECT_NAME}
)
