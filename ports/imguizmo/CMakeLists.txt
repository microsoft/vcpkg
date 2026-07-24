cmake_minimum_required(VERSION 3.8)
project(imguizmo)

set(CMAKE_CXX_STANDARD 17)

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
        src/GraphEditor.cpp
        src/ImCurveEdit.cpp
        src/ImGradient.cpp
        src/ImGuizmo.cpp
        src/ImSequencer.cpp
        src/ImVectorEditor.cpp
)

install(
    TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}-target
    ARCHIVE DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

if (NOT IMGUIZMO_SKIP_HEADERS)
    install(
        FILES
            src/GraphEditor.h
            src/ImCurveEdit.h
            src/ImGradient.h
            src/ImGuizmo.h
            src/ImLightRig.h
            src/ImSequencer.h
            src/ImVectorEditor.h
            src/ImZoomSlider.h
        DESTINATION include
    )
endif()

install(
    EXPORT ${PROJECT_NAME}-target
    NAMESPACE ${PROJECT_NAME}::
    FILE ${PROJECT_NAME}-config.cmake
    DESTINATION share/${PROJECT_NAME}
)
