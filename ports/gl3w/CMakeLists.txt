cmake_minimum_required(VERSION 3.9)
project(gl3w C)

find_package(OpenGL REQUIRED)
find_path(GLCOREARB_H NAMES GL/glcorearb.h)

add_library(gl3w src/gl3w.c)

target_include_directories(gl3w
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
        $<INSTALL_INTERFACE:include>
    PRIVATE
        ${GLCOREARB_H}
        ${OPENGL_INCLUDE_DIR}
)

if(BUILD_SHARED_LIBS)
    target_compile_definitions(gl3w PRIVATE "-DGL3W_API=__declspec(dllexport)")
endif()

target_link_libraries(gl3w PRIVATE ${OPENGL_LIBRARIES})

install(TARGETS gl3w
    EXPORT gl3wExport
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(
    EXPORT gl3wExport
    FILE gl3wConfig.cmake
    NAMESPACE unofficial::gl3w::
    DESTINATION share/gl3w
)

if(NOT DISABLE_INSTALL_HEADERS)
    install(FILES include/GL/gl3w.h DESTINATION include/GL)
endif()
