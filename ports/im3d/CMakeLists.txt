cmake_minimum_required(VERSION 3.8)
project(im3d)

set(CMAKE_CXX_STANDARD 11)

add_library(${PROJECT_NAME} "")

target_include_directories(
	${PROJECT_NAME}
	PUBLIC
	   	$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
		$<INSTALL_INTERFACE:include>
)

target_sources(
    ${PROJECT_NAME}
    PRIVATE
        im3d.cpp
)

install(
    TARGETS ${PROJECT_NAME}
    EXPORT unofficial-${PROJECT_NAME}-target
    ARCHIVE DESTINATION lib
    ARCHIVE DESTINATION lib
    RUNTIME DESTINATION bin
)

if (NOT IM3D_SKIP_HEADERS)
    install(
        FILES
            im3d.h
            im3d_config.h
            im3d_math.h
        DESTINATION include
    )
endif()

install(
    EXPORT unofficial-${PROJECT_NAME}-target
    NAMESPACE unofficial::${PROJECT_NAME}::
    FILE unofficial-${PROJECT_NAME}-config.cmake
    DESTINATION share/unofficial-${PROJECT_NAME}
)
