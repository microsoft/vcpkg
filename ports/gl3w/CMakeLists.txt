cmake_minimum_required(VERSION 3.9)

project(gl3w)

set(SOURCE_DIR ${CMAKE_CURRENT_BINARY_DIR}/src)
set(HEADER_DIR ${CMAKE_CURRENT_BINARY_DIR}/include)

set(HEADER_FILES
	"${HEADER_DIR}/GL/gl3w.h"
	"${HEADER_DIR}/GL/glcorearb.h"
)

set(SOURCE_FILES
	"${SOURCE_DIR}/gl3w.c"
)

find_package(OpenGL REQUIRED)

# add command to create the header and source files
add_custom_command(
	OUTPUT
		"${SOURCE_DIR}/gl3w.c"
		"${HEADER_DIR}/GL/gl3w.h"
		"${HEADER_DIR}/GL/glcorearb.h"
	COMMAND python ${CMAKE_CURRENT_SOURCE_DIR}/gl3w_gen.py
	DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/gl3w_gen.py
	WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
)

# add pseudo target that depends on the generated files
add_custom_target(
	gl3w_gen ALL
	DEPENDS
		"${SOURCE_DIR}/gl3w.c"
		"${HEADER_DIR}/GL/gl3w.h"
		"${HEADER_DIR}/GL/glcorearb.h"
)

add_library(${PROJECT_NAME} ${SOURCE_FILES})

add_dependencies(${PROJECT_NAME} gl3w_gen)

target_include_directories(${PROJECT_NAME} PUBLIC
	$<BUILD_INTERFACE:${HEADER_DIR}>
	$<INSTALL_INTERFACE:include>
)

if(BUILD_SHARED_LIBS)
    target_compile_definitions(${PROJECT_NAME} PRIVATE -DGL3W_EXPORTS)
endif()

target_include_directories(${PROJECT_NAME} PRIVATE ${OPENGL_INCLUDE_DIR})
target_link_libraries(${PROJECT_NAME} PRIVATE ${OPENGL_LIBRARIES})

install(TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}Export
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(EXPORT ${PROJECT_NAME}Export FILE ${PROJECT_NAME}Config.cmake NAMESPACE ${PROJECT_NAME}:: DESTINATION share/${PROJECT_NAME})

if(NOT DISABLE_INSTALL_HEADERS)
    install(DIRECTORY ${HEADER_DIR}/GL
        DESTINATION include)
endif()
