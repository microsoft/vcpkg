cmake_minimum_required(VERSION 3.8)
project(imguizmo)

set(CMAKE_CXX_STANDARD 11)

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
        GraphEditor.cpp
        ImCurveEdit.cpp
        ImGradient.cpp
        ImGuizmo.cpp
        ImSequencer.cpp
)

install(
    TARGETS ${PROJECT_NAME}
    EXPORT unofficial-${PROJECT_NAME}-target
    ARCHIVE DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

if (NOT IMGUIZMO_SKIP_HEADERS)
    install(
        FILES
            GraphEditor.h
            ImCurveEdit.h
            ImGradient.h
            ImGuizmo.h
            ImSequencer.h
            ImZoomSlider.h
        DESTINATION include
    )
endif()

install(
    EXPORT unofficial-${PROJECT_NAME}-target
    NAMESPACE unofficial::${PROJECT_NAME}::
    FILE unofficial-${PROJECT_NAME}-config.cmake
    DESTINATION share/unofficial-${PROJECT_NAME}
)
