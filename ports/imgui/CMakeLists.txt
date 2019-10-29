cmake_minimum_required(VERSION 3.8)
project(imgui CXX)

set(IMGUI_INCLUDES_PUBLIC
    imgui.h
    imconfig.h
    imgui_internal.h
    imstb_rectpack.h
    imstb_textedit.h
    imstb_truetype.h
)

set(IMGUI_SOURCES
    imgui.cpp
    imgui_demo.cpp
    imgui_draw.cpp
    imgui_widgets.cpp
)

file(GLOB IMGUI_INCLUDES_EXAMPLES examples/*.h)
file(GLOB IMGUI_SOURCES_EXAMPLES examples/*.cpp)

add_library(${PROJECT_NAME} INTERFACE)

target_include_directories(${PROJECT_NAME} INTERFACE
                           $<INSTALL_INTERFACE:include>
                           $<BUILD_INTERFACE:.>)

install(TARGETS ${PROJECT_NAME}
    EXPORT IMGUIExport
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(EXPORT IMGUIExport FILE ${PROJECT_NAME}Config.cmake NAMESPACE ${PROJECT_NAME}:: DESTINATION share/${PROJECT_NAME})

install(FILES ${IMGUI_INCLUDES_PUBLIC} ${IMGUI_SOURCES} ${IMGUI_INCLUDES_EXAMPLES} ${IMGUI_SOURCES_EXAMPLES} DESTINATION include)