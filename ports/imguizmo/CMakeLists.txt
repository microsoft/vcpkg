cmake_minimum_required(VERSION 3.8)
project(imguizmo)

find_package(imgui CONFIG REQUIRED)
get_target_property(IMGUI_INCLUDE_DIRS imgui::imgui
    INTERFACE_INCLUDE_DIRECTORIES
)

add_library(${PROJECT_NAME} "")
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_compile_options(${PROJECT_NAME} PRIVATE "-std=c++11")

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
        ${CMAKE_CURRENT_SOURCE_DIR}/GraphEditor.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/ImCurveEdit.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/ImGradient.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/ImGuizmo.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/ImSequencer.cpp
)

install(
    TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}_target
    ARCHIVE DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

if (NOT IMGUIZMO_SKIP_HEADERS)
    install(
        FILES
            ${CMAKE_CURRENT_SOURCE_DIR}/GraphEditor.h
            ${CMAKE_CURRENT_SOURCE_DIR}/ImCurveEdit.h
            ${CMAKE_CURRENT_SOURCE_DIR}/ImGradient.h
            ${CMAKE_CURRENT_SOURCE_DIR}/ImGuizmo.h
            ${CMAKE_CURRENT_SOURCE_DIR}/ImSequencer.h
            ${CMAKE_CURRENT_SOURCE_DIR}/ImZoomSlider.h
        DESTINATION include
    )
endif()

install(
    EXPORT ${PROJECT_NAME}_target
    NAMESPACE ${PROJECT_NAME}::
    FILE ${PROJECT_NAME}-config.cmake
    DESTINATION share/${PROJECT_NAME}
)