cmake_minimum_required(VERSION 3.8)
project(imgui CXX)

find_path(STB_INCLUDE_DIR stb_rect_pack.h stb_textedit.h stb_truetype.h)

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
)

add_library(imgui STATIC
    ${IMGUI_INCLUDES_PUBLIC}
    ${IMGUI_INCLUDES_PRIVATE}
    ${IMGUI_SOURCES}
)

target_include_directories(imgui
    PRIVATE
    ${IMGUI_INCLUDES_PRIVATE}
    ${STB_INCLUDE_DIR}

    PUBLIC
    ${IMGUI_INCLUDES_PUBLIC}
)

install(TARGETS imgui
    ARCHIVE DESTINATION lib
)

if(NOT IMGUI_SKIP_HEADERS)
    install(
        FILES ${IMGUI_INCLUDES_PUBLIC}
        DESTINATION include
    )
endif()
