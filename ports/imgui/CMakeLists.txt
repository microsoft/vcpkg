cmake_minimum_required(VERSION 3.8)
project(imgui CXX)

set(CMAKE_DEBUG_POSTFIX d)

set(IMGUI_INCLUDES_PUBLIC
    imgui.h
    imconfig.h
)

set(IMGUI_INCLUDES_PRIVATE
    imgui_internal.h
)

set(IMGUI_SOURCES
    imgui.cpp
    imgui_demo.cpp
    imgui_draw.cpp
    imgui_widgets.cpp
)

if (IMGUI_INCLUDE_IMPL_VULKAN)
    find_package(vulkan)

    list (APPEND IMGUI_INCLUDES_PUBLIC examples/imgui_impl_vulkan.h)
    list (APPEND IMGUI_SOURCES examples/imgui_impl_vulkan.cpp)
endif()

if (IMGUI_INCLUDE_IMPL_SDL2)
    find_package(SDL2 CONFIG REQUIRED)

    list (APPEND IMGUI_INCLUDES_PUBLIC examples/imgui_impl_sdl.h)
    list (APPEND IMGUI_SOURCES examples/imgui_impl_sdl.cpp)
endif()


add_library(${PROJECT_NAME}
    ${IMGUI_INCLUDES_PUBLIC}
    ${IMGUI_INCLUDES_PRIVATE}
    ${IMGUI_SOURCES}
)

if (IMGUI_INCLUDE_IMPL_VULKAN)
    target_link_libraries(${PROJECT_NAME} PUBLIC Vulkan::Vulkan)
endif()

if (IMGUI_INCLUDE_IMPL_SDL2)
    target_link_libraries(${PROJECT_NAME} PUBLIC SDL2::SDL2main SDL2::SDL2-static)
endif()

target_include_directories(${PROJECT_NAME} PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>)

install(TARGETS ${PROJECT_NAME}
    EXPORT IMGUIExport
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(EXPORT IMGUIExport FILE ${PROJECT_NAME}Config.cmake NAMESPACE ${PROJECT_NAME}:: DESTINATION share/${PROJECT_NAME})

if(NOT IMGUI_SKIP_HEADERS)
    install(
        FILES ${IMGUI_INCLUDES_PUBLIC}
        DESTINATION include
    )
endif()
