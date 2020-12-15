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


if(IMGUI_USE_WCHAR32)
    FILE(READ ${CMAKE_CURRENT_SOURCE_DIR}/imconfig.h IMCONFIG)
    STRING(REGEX REPLACE "//#define IMGUI_USE_WCHAR32" "#define IMGUI_USE_WCHAR32" IMCONFIG "${IMCONFIG}")
    FILE(WRITE ${CMAKE_CURRENT_SOURCE_DIR}/imconfig.h "${IMCONFIG}")
endif()

set(BINDING_TARGETS )
set(BINDINGS_SOURCES)
if(IMGUI_INSTALL_ALLEGRO5_BINDING)
    find_path(ALLEGRO5_INCLUDE_DIRS allegro5/allegro.h)
    add_library(imgui_impl_allegro5 INTERFACE)
    set_property(TARGET imgui_impl_allegro5 PROPERTY INTERFACE_SOURCES $<INSTALL_INTERFACE: examples/imgui_impl_allegro5.cpp>)
    set_property(TARGET imgui_impl_allegro5 PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${ALLEGRO5_INCLUDE_DIRS})
    set_property(TARGET imgui_impl_allegro5 PROPERTY INTERFACE_LINK_LIBRARIES ${PROJECT_NAME})
    list(APPEND BINDING_TARGETS imgui_impl_allegro5)
    list(APPEND BINDINGS_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_allegro5.cpp)
endif()

if(IMGUI_INSTALL_DX9_BINDING)
    add_library(imgui_impl_dx9 INTERFACE)
    add_dependencies(imgui_impl_dx9 ${PROJECT_NAME})
    set_property(TARGET imgui_impl_dx9 PROPERTY INTERFACE_SOURCES $<INSTALL_INTERFACE: examples/imgui_impl_dx9.cpp>)
    set_property(TARGET imgui_impl_dx9 PROPERTY INTERFACE_LINK_LIBRARIES ${PROJECT_NAME})
    list(APPEND BINDING_TARGETS imgui_impl_dx9)
    list(APPEND BINDINGS_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_dx9.cpp)
endif()

if(IMGUI_INSTALL_DX10_BINDING)
    add_library(imgui_impl_dx10 INTERFACE)
    add_dependencies(imgui_impl_dx10 ${PROJECT_NAME})
    set_property(TARGET imgui_impl_dx10 PROPERTY INTERFACE_SOURCES $<INSTALL_INTERFACE: examples/imgui_impl_dx10.cpp>)
    set_property(TARGET imgui_impl_dx10 PROPERTY INTERFACE_LINK_LIBRARIES ${PROJECT_NAME})
    list(APPEND BINDING_TARGETS imgui_impl_dx10)
    list(APPEND BINDINGS_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_dx10.cpp)
endif()

if(IMGUI_INSTALL_DX11_BINDING)
    add_library(imgui_impl_dx11 INTERFACE)
    add_dependencies(imgui_impl_dx11 ${PROJECT_NAME})
    set_property(TARGET imgui_impl_dx11 PROPERTY INTERFACE_SOURCES $<INSTALL_INTERFACE: examples/imgui_impl_dx11.cpp>)
    set_property(TARGET imgui_impl_dx11 PROPERTY INTERFACE_LINK_LIBRARIES ${PROJECT_NAME})
    list(APPEND BINDING_TARGETS imgui_impl_dx11)
    list(APPEND BINDINGS_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_dx11.cpp)
endif()

if(IMGUI_INSTALL_DX12_BINDING)
    add_library(imgui_impl_dx12 INTERFACE)
    add_dependencies(imgui_impl_dx12 ${PROJECT_NAME})
    set_property(TARGET imgui_impl_dx12 PROPERTY INTERFACE_SOURCES $<INSTALL_INTERFACE: examples/imgui_impl_dx12.cpp>)
    set_property(TARGET imgui_impl_dx12 PROPERTY INTERFACE_LINK_LIBRARIES ${PROJECT_NAME})
    if (WIN32)
        set_property(TARGET imgui_impl_dx12 PROPERTY INTERFACE_LINK_LIBRARIES D3D12)
    endif()
    list(APPEND BINDING_TARGETS imgui_impl_dx12)
    list(APPEND BINDINGS_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_dx12.cpp)
endif()

if(IMGUI_INSTALL_GLFW_BINDING)
    find_package(glfw3 CONFIG REQUIRED)
    add_library(imgui_impl_glfw INTERFACE)
    set_property(TARGET imgui_impl_glfw PROPERTY INTERFACE_SOURCES $<INSTALL_INTERFACE: examples/imgui_impl_glfw.cpp>)
    set_property(TARGET imgui_impl_glfw PROPERTY INTERFACE_LINK_LIBRARIES glfw ${PROJECT_NAME})
    list(APPEND BINDING_TARGETS imgui_impl_glfw)
    list(APPEND BINDINGS_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_glfw.cpp)
endif()

if(IMGUI_INSTALL_GLUT_BINDING)
    find_package(GLUT REQUIRED)
    add_library(imgui_impl_glut INTERFACE)
    add_dependencies(imgui_impl_glut ${PROJECT_NAME})
    set_property(TARGET imgui_impl_glut PROPERTY INTERFACE_SOURCES $<INSTALL_INTERFACE: examples/imgui_impl_glut.cpp>)
    set_property(TARGET imgui_impl_glut PROPERTY INTERFACE_LINK_LIBRARIES GLUT::GLUT ${PROJECT_NAME})
    list(APPEND BINDING_TARGETS imgui_impl_glut)
    list(APPEND BINDINGS_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_glut.cpp)
endif()

if(IMGUI_INSTALL_METAL_BINDING)
    add_library(imgui_impl_metal INTERFACE)
    add_dependencies(imgui_impl_metal ${PROJECT_NAME})
    set_property(TARGET imgui_impl_metal PROPERTY INTERFACE_SOURCES $<INSTALL_INTERFACE: examples/imgui_impl_metal.mm>)
    set_property(TARGET imgui_impl_metal PROPERTY INTERFACE_LINK_LIBRARIES ${PROJECT_NAME})
    list(APPEND BINDING_TARGETS imgui_impl_metal)
    list(APPEND BINDINGS_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_metal.mm)
endif()

if(IMGUI_INSTALL_OPENGL2_BINDING)
    add_library(imgui_impl_opengl2 INTERFACE)
    add_dependencies(imgui_impl_opengl2 ${PROJECT_NAME})
    set_property(TARGET imgui_impl_opengl2 PROPERTY INTERFACE_SOURCES $<INSTALL_INTERFACE: examples/imgui_impl_opengl2.cpp>)
    set_property(TARGET imgui_impl_opengl2 PROPERTY INTERFACE_LINK_LIBRARIES Opengl32 ${PROJECT_NAME})
    list(APPEND BINDING_TARGETS imgui_impl_opengl2)
    list(APPEND BINDINGS_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_opengl2.cpp)
endif()

if(IMGUI_INSTALL_OPENGL3_GLEW_BINDING)
    find_package(GLEW REQUIRED)
    add_library(imgui_impl_opengl3_glew INTERFACE)
    add_dependencies(imgui_impl_opengl3_glew ${PROJECT_NAME})
    set_property(TARGET imgui_impl_opengl3_glew PROPERTY INTERFACE_SOURCES $<INSTALL_INTERFACE: examples/imgui_impl_opengl3.cpp>)
    set_property(TARGET imgui_impl_opengl3_glew PROPERTY INTERFACE_LINK_LIBRARIES GLEW::GLEW ${PROJECT_NAME})
    set_property(TARGET imgui_impl_opengl3_glew PROPERTY INTERFACE_COMPILE_DEFINITIONS IMGUI_IMPL_OPENGL_LOADER_GLEW)
    list(APPEND BINDING_TARGETS imgui_impl_opengl3_glew)
    list(APPEND BINDINGS_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_opengl3.cpp)
endif()

if(IMGUI_INSTALL_OPENGL3_GLAD_BINDING)
    find_package(glad REQUIRED)
    add_library(imgui_impl_opengl3_glad INTERFACE)
    add_dependencies(imgui_impl_opengl3_glad ${PROJECT_NAME})
    set_property(TARGET imgui_impl_opengl3_glad PROPERTY INTERFACE_SOURCES $<INSTALL_INTERFACE: examples/imgui_impl_opengl3.cpp>)
    set_property(TARGET imgui_impl_opengl3_glad PROPERTY INTERFACE_LINK_LIBRARIES glad::glad ${PROJECT_NAME})
    set_property(TARGET imgui_impl_opengl3_glad PROPERTY INTERFACE_COMPILE_DEFINITIONS IMGUI_IMPL_OPENGL_LOADER_GLAD)
    list(APPEND BINDING_TARGETS imgui_impl_opengl3_glad)
    list(APPEND BINDINGS_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_opengl3.cpp)
endif()

if(IMGUI_INSTALL_OPENGL3_GL3W_BINDING)
    find_package(gl3w REQUIRED)
    add_library(imgui_impl_opengl3_glw3 INTERFACE)
    add_dependencies(imgui_impl_opengl3_glw3 ${PROJECT_NAME})
    set_property(TARGET imgui_impl_opengl3_glw3 PROPERTY INTERFACE_SOURCES $<INSTALL_INTERFACE: examples/imgui_impl_opengl3.cpp>)
    set_property(TARGET imgui_impl_opengl3_glw3 PROPERTY INTERFACE_LINK_LIBRARIES unofficial::gl3w::gl3w ${PROJECT_NAME})
    set_property(TARGET imgui_impl_opengl3_glw3 PROPERTY INTERFACE_COMPILE_DEFINITIONS IMGUI_IMPL_OPENGL_LOADER_GL3W)
    list(APPEND BINDING_TARGETS imgui_impl_opengl3_glw3)
    list(APPEND BINDINGS_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_opengl3.cpp)
endif()

if(IMGUI_INSTALL_OPENGL3_GLBINDING_BINDING)
    find_package(glbinding REQUIRED)
    add_library(imgui_impl_opengl3_glbinding INTERFACE)
    add_dependencies(imgui_impl_opengl3_glbinding ${PROJECT_NAME})
    set_property(TARGET imgui_impl_opengl3_glbinding PROPERTY INTERFACE_SOURCES $<INSTALL_INTERFACE: examples/imgui_impl_opengl3.cpp>)
    set_property(TARGET imgui_impl_opengl3_glbinding PROPERTY INTERFACE_LINK_LIBRARIES glbinding::glbinding ${PROJECT_NAME})
    set_property(TARGET imgui_impl_opengl3_glbinding PROPERTY INTERFACE_COMPILE_DEFINITIONS IMGUI_IMPL_OPENGL_LOADER_GLBINDING3)
    list(APPEND BINDING_TARGETS imgui_impl_opengl3_glbinding)
    list(APPEND BINDINGS_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_opengl3.cpp)
endif()

if(IMGUI_INSTALL_OSX_BINDING)
    add_library(imgui_impl_osx INTERFACE)
    add_dependencies(imgui_impl_osx ${PROJECT_NAME})
    set_property(TARGET imgui_impl_osx PROPERTY INTERFACE_SOURCES $<INSTALL_INTERFACE: examples/imgui_impl_osx.mm>)
    set_property(TARGET imgui_impl_osx PROPERTY INTERFACE_LINK_LIBRARIES ${PROJECT_NAME})
    list(APPEND BINDING_TARGETS imgui_impl_osx)
    list(APPEND BINDINGS_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_osx.mm)
endif()

if(IMGUI_INSTALL_SDL2_BINDING)
    find_package(SDL2 CONFIG REQUIRED)
    add_library(imgui_impl_sdl INTERFACE)
    add_dependencies(imgui_impl_sdl ${PROJECT_NAME})
    set_property(TARGET imgui_impl_sdl PROPERTY INTERFACE_SOURCES $<INSTALL_INTERFACE: examples/imgui_impl_sdl.cpp>)
    set_property(TARGET imgui_impl_sdl PROPERTY INTERFACE_LINK_LIBRARIES SDL2::SDL2 ${PROJECT_NAME})
    list(APPEND BINDING_TARGETS imgui_impl_sdl)
    list(APPEND BINDINGS_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_sdl.cpp)
endif()

if(IMGUI_INSTALL_VULKAN_BINDING)
    find_package(Vulkan REQUIRED)
    add_library(imgui_impl_vulkan INTERFACE)
    add_dependencies(imgui_impl_vulkan ${PROJECT_NAME})
    set_property(TARGET imgui_impl_vulkan PROPERTY INTERFACE_SOURCES $<INSTALL_INTERFACE: examples/imgui_impl_vulkan.cpp>)
    set_property(TARGET imgui_impl_vulkan PROPERTY INTERFACE_LINK_LIBRARIES Vulkan::Vulkan ${PROJECT_NAME})
    list(APPEND BINDING_TARGETS imgui_impl_vulkan)
    list(APPEND BINDINGS_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_vulkan.cpp)
endif()

if(IMGUI_INSTALL_WIN32_BINDING)
    add_library(imgui_impl_win32 INTERFACE)
    add_dependencies(imgui_impl_win32 ${PROJECT_NAME})
    set_property(TARGET imgui_impl_win32 PROPERTY INTERFACE_SOURCES $<INSTALL_INTERFACE: examples/imgui_impl_win32.cpp>)
    set_property(TARGET imgui_impl_win32 PROPERTY INTERFACE_LINK_LIBRARIES ${PROJECT_NAME})
    list(APPEND BINDING_TARGETS imgui_impl_win32)
    list(APPEND BINDINGS_SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_win32.cpp)
endif()

if(IMGUI_FREETYPE)
    find_package(Freetype REQUIRED)
    target_include_directories(${PROJECT_NAME} PRIVATE ${FREETYPE_INCLUDE_DIRS})
    target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/misc/freetype/imgui_freetype.cpp)
endif()

list(REMOVE_DUPLICATES BINDINGS_SOURCES)

install(
    TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}_target
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

foreach(BINDING_TARGET ${BINDING_TARGETS})
    install(
        TARGETS ${BINDING_TARGET}
        EXPORT ${PROJECT_NAME}_target
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
        RUNTIME DESTINATION bin
    )
endforeach()

if(NOT IMGUI_SKIP_HEADERS)
    install(FILES
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui.h
        ${CMAKE_CURRENT_SOURCE_DIR}/imconfig.h
        ${CMAKE_CURRENT_SOURCE_DIR}/imgui_internal.h
        ${CMAKE_CURRENT_SOURCE_DIR}/imstb_textedit.h
        ${CMAKE_CURRENT_SOURCE_DIR}/imstb_rectpack.h
        ${CMAKE_CURRENT_SOURCE_DIR}/imstb_truetype.h
        ${CMAKE_CURRENT_SOURCE_DIR}/misc/cpp/imgui_stdlib.h
        DESTINATION include
    )

    if(IMGUI_INSTALL_ALLEGRO5_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_allegro5.h DESTINATION include)
    endif()

    if(IMGUI_INSTALL_DX9_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_dx9.h DESTINATION include)
    endif()

    if(IMGUI_INSTALL_DX10_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_dx10.h DESTINATION include)
    endif()

    if(IMGUI_INSTALL_DX11_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_dx11.h DESTINATION include)
    endif()

    if(IMGUI_INSTALL_DX12_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_dx12.h DESTINATION include)
    endif()

    if(IMGUI_INSTALL_GLFW_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_glfw.h DESTINATION include)
    endif()

    if(IMGUI_INSTALL_GLUT_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_glut.h DESTINATION include)
    endif()

    if(IMGUI_COPY_MARMALADE_BINDING)
        file(GLOB MARMALADE_BINDING_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_marmalade.*)
        install(FILES ${MARMALADE_BINDING_SRCS} DESTINATION include/bindings)
    endif()

    if(IMGUI_INSTALL_METAL_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_metal.h DESTINATION include)
    endif()

    if(IMGUI_INSTALL_OPENGL2_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_opengl2.h DESTINATION include)
    endif()

    if(IMGUI_INSTALL_OPENGL3_GLEW_BINDING OR IMGUI_INSTALL_OPENGL3_GLAD_BINDING
        OR IMGUI_INSTALL_OPENGL3_GL3W_BINDING OR IMGUI_INSTALL_OPENGL3_GLBINDING_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_opengl3.h DESTINATION include)
    endif()

    if(IMGUI_INSTALL_OSX_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_osx.h DESTINATION include)
    endif()

    if(IMGUI_INSTALL_SDL2_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_sdl.h DESTINATION include)
    endif()

    if(IMGUI_INSTALL_VULKAN_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_vulkan.h DESTINATION include)
    endif()

    if(IMGUI_INSTALL_WIN32_BINDING)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_win32.h DESTINATION include)
    endif()

    if(IMGUI_FREETYPE)
        install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/misc/freetype/imgui_freetype.h DESTINATION include)
    endif()
    
    if (BINDINGS_SOURCES)
        install(FILES ${BINDINGS_SOURCES} DESTINATION examples)
    endif()
endif()

include(CMakePackageConfigHelpers)
configure_package_config_file(imgui-config.cmake.in imgui-config.cmake INSTALL_DESTINATION share/imgui)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/imgui-config.cmake DESTINATION share/imgui)

install(
    EXPORT ${PROJECT_NAME}_target
    NAMESPACE ${PROJECT_NAME}::
    FILE ${PROJECT_NAME}-targets.cmake
    DESTINATION share/${PROJECT_NAME}
)
