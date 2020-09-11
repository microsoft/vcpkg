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

if(IMGUI_BUILD_ALLEGRO5_BINDING)
	find_path(ALLEGRO5_INCLUDE_DIRS allegro5/allegro.h)
	target_include_directories(${PROJECT_NAME} PRIVATE ${ALLEGRO5_INCLUDE_DIRS})
	target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_allegro5.cpp)
endif()

if(IMGUI_BUILD_DX9_BINDING)
	target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_dx9.cpp)
endif()

if(IMGUI_BUILD_DX10_BINDING)
	target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_dx10.cpp)
endif()

if(IMGUI_BUILD_DX11_BINDING)
	target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_dx11.cpp)
endif()

if(IMGUI_BUILD_DX12_BINDING)
	target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_dx12.cpp)
endif()

if(IMGUI_BUILD_GLFW_BINDING)
	find_package(glfw3 REQUIRED)
	get_target_property(GLFW3_INCLUDE_DIRS glfw INTERFACE_INCLUDE_DIRECTORIES)
	target_include_directories(${PROJECT_NAME} PRIVATE ${GLFW3_INCLUDE_DIRS})
	target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_glfw.cpp)
endif()

if(IMGUI_BUILD_GLUT_BINDING)
	find_path(GLUT_INCLUDE_DIRS GL/freeglut.h)
	target_include_directories(${PROJECT_NAME} PRIVATE ${GLUT_INCLUDE_DIRS})
	target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_glut.cpp)
endif()

if(IMGUI_BUILD_METAL_BINDING)
	target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_metal.mm)
endif()

if(IMGUI_BUILD_OPENGL2_BINDING)
	target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_opengl2.cpp)
endif()

if(IMGUI_BUILD_OPENGL3_GLEW_BINDING)
	find_package(glew REQUIRED)
	target_include_directories(${PROJECT_NAME} PRIVATE ${GLEW_INCLUDE_DIRS})
	target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_opengl3.cpp)
endif()

if(IMGUI_BUILD_OPENGL3_GLAD_BINDING)
	find_package(glad REQUIRED)
	get_target_property(GLAD_INCLUDE_DIRS glad::glad INTERFACE_INCLUDE_DIRECTORIES)
	target_include_directories(${PROJECT_NAME} PRIVATE ${GLAD_INCLUDE_DIRS})
	target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_opengl3.cpp)
endif()

if(IMGUI_BUILD_OPENGL3_GL3W_BINDING)
	find_package(gl3w REQUIRED)
	get_target_property(GL3W_INCLUDE_DIRS unofficial::gl3w::gl3w INTERFACE_INCLUDE_DIRECTORIES)
	target_include_directories(${PROJECT_NAME} PRIVATE ${GL3W_INCLUDE_DIRS})
	target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_opengl3.cpp)
endif()

if(IMGUI_BUILD_OPENGL3_GLBINDING_BINDING)
	find_package(glbinding REQUIRED)
	get_target_property(GLBINDING_INCLUDE_DIRS glbinding::glbinding INTERFACE_INCLUDE_DIRECTORIES)
	target_include_directories(${PROJECT_NAME} PRIVATE ${GLBINDING_INCLUDE_DIRS})
	target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_opengl3.cpp)
endif()

if(IMGUI_BUILD_OSX_BINDING)
	target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_osx.mm)
endif()

if(IMGUI_BUILD_SDL2_BINDING)
	find_package(SDL2 CONFIG REQUIRED)
	find_path(SDL2_INCLUDE_DIRS SDL2/SDL.h)
	target_include_directories(${PROJECT_NAME} PRIVATE ${SDL2_INCLUDE_DIRS} ${SDL2_INCLUDE_DIRS}/SDL2)
	target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_sdl.cpp)
endif()

if(IMGUI_BUILD_VULKAN_BINDING)
    find_package(Vulkan REQUIRED)
	get_target_property(VULKAN_INCLUDE_DIRS Vulkan::Vulkan INTERFACE_INCLUDE_DIRECTORIES)
	target_include_directories(${PROJECT_NAME} PRIVATE ${VULKAN_INCLUDE_DIRS})
	target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_vulkan.cpp)
endif()

if(IMGUI_BUILD_WIN32_BINDING)
	target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_win32.cpp)
endif()

if(IMGUI_FREETYPE)
	find_package(Freetype REQUIRED)
	target_include_directories(${PROJECT_NAME} PRIVATE ${FREETYPE_INCLUDE_DIRS})
	target_sources(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/misc/freetype/imgui_freetype.cpp)
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
        ${CMAKE_CURRENT_SOURCE_DIR}/imstb_rectpack.h
        ${CMAKE_CURRENT_SOURCE_DIR}/imstb_truetype.h
        ${CMAKE_CURRENT_SOURCE_DIR}/misc/cpp/imgui_stdlib.h
        DESTINATION include
    )

	if(IMGUI_BUILD_ALLEGRO5_BINDING)
		install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_allegro5.h DESTINATION include)
	endif()

	if(IMGUI_BUILD_DX9_BINDING)
		install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_dx9.h DESTINATION include)
	endif()

	if(IMGUI_BUILD_DX10_BINDING)
		install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_dx10.h DESTINATION include)
	endif()

	if(IMGUI_BUILD_DX11_BINDING)
		install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_dx11.h DESTINATION include)
	endif()

	if(IMGUI_BUILD_DX12_BINDING)
		install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_dx12.h DESTINATION include)
	endif()

	if(IMGUI_BUILD_GLFW_BINDING)
		install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_glfw.h DESTINATION include)
	endif()

	if(IMGUI_BUILD_GLUT_BINDING)
		install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_glut.h DESTINATION include)
	endif()

	if(IMGUI_COPY_MARMALADE_BINDING)
		file(GLOB MARMALADE_BINDING_SRCS ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_marmalade.*)
		install(FILES ${MARMALADE_BINDING_SRCS} DESTINATION include/bindings)
	endif()

	if(IMGUI_BUILD_METAL_BINDING)
		install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_metal.h DESTINATION include)
	endif()

	if(IMGUI_BUILD_OPENGL2_BINDING)
		install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_opengl2.h DESTINATION include)
	endif()

	if(IMGUI_BUILD_OPENGL3_GLEW_BINDING OR IMGUI_BUILD_OPENGL3_GLAD_BINDING OR IMGUI_BUILD_OPENGL3_GL3W_BINDING OR IMGUI_BUILD_OPENGL3_GLBINDING_BINDING)
		install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_opengl3.h DESTINATION include)
	endif()

	if(IMGUI_BUILD_OSX_BINDING)
		install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_osx.h DESTINATION include)
	endif()

	if(IMGUI_BUILD_SDL2_BINDING)
		install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_sdl.h DESTINATION include)
	endif()

	if(IMGUI_BUILD_VULKAN_BINDING)
		install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_vulkan.h DESTINATION include)
	endif()

	if(IMGUI_BUILD_WIN32_BINDING)
		install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/examples/imgui_impl_win32.h DESTINATION include)
	endif()

	if(IMGUI_FREETYPE)
		install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/misc/freetype/imgui_freetype.h DESTINATION include)
	endif()
endif()

install(
	EXPORT ${PROJECT_NAME}_target
	NAMESPACE ${PROJECT_NAME}::
	FILE ${PROJECT_NAME}-config.cmake
	DESTINATION share/${PROJECT_NAME}
)
