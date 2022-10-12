cmake_minimum_required(VERSION 3.8)
project(im3d)

add_library(${PROJECT_NAME} "")
add_library(${PROJECT_NAME}::${PROJECT_NAME} ALIAS ${PROJECT_NAME})

target_compile_options(${PROJECT_NAME} PRIVATE "-std=c++11")

target_include_directories(
	${PROJECT_NAME}
	PUBLIC
	   	$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
		$<INSTALL_INTERFACE:include>
)

target_sources(
    ${PROJECT_NAME}
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/im3d.cpp
)

install(
    TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}_target
    ARCHIVE DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

if (NOT IM3D_SKIP_HEADERS)
    install(
        FILES
            ${CMAKE_CURRENT_SOURCE_DIR}/im3d.h
            ${CMAKE_CURRENT_SOURCE_DIR}/im3d_config.h
            ${CMAKE_CURRENT_SOURCE_DIR}/im3d_math.h
        DESTINATION include
    )
endif()

install(
    EXPORT ${PROJECT_NAME}_target
    NAMESPACE ${PROJECT_NAME}::
    FILE ${PROJECT_NAME}-config.cmake
    DESTINATION share/${PROJECT_NAME}
)