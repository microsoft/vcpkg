cmake_minimum_required(VERSION 3.8)
project(imgui-node-editor)

set(CMAKE_CXX_STANDARD 14)

find_package(imgui CONFIG REQUIRED)
get_target_property(IMGUI_INCLUDE_DIRS imgui::imgui
    INTERFACE_INCLUDE_DIRECTORIES
)

add_library(${PROJECT_NAME} "")

target_include_directories(
	${PROJECT_NAME}
	PUBLIC
	   	$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
		$<INSTALL_INTERFACE:include>
	PRIVATE
		${IMGUI_INCLUDE_DIRS}
)

target_sources(
    ${PROJECT_NAME}
    PRIVATE
        crude_json.cpp
        imgui_canvas.cpp
        imgui_node_editor.cpp
        imgui_node_editor_api.cpp
)

install(
    TARGETS ${PROJECT_NAME}
    EXPORT unofficial-${PROJECT_NAME}-target
    ARCHIVE DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

if (NOT IMGUI_NODE_EDITOR_SKIP_HEADERS)
    install(
        FILES
            crude_json.h
            imgui_bezier_math.h
            imgui_bezier_math.inl
            imgui_canvas.h
            imgui_extra_math.h
            imgui_extra_math.inl
            imgui_node_editor.h
            imgui_node_editor_internal.h
            imgui_node_editor_internal.inl
        DESTINATION include/${PROJECT_NAME}
    )
endif()

install(
    EXPORT unofficial-${PROJECT_NAME}-target
    NAMESPACE unofficial::${PROJECT_NAME}::
    FILE unofficial-${PROJECT_NAME}-config.cmake
    DESTINATION share/unofficial-${PROJECT_NAME}
)
