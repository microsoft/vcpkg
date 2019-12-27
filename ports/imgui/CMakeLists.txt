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

set(IMGUI_CPP_PUBLIC
    misc/cpp/imgui_stdlib.h
)
set(IMGUI_CPP_SOURCES
    misc/cpp/imgui_stdlib.cpp
)

set(IMGUI_FONTS_RESOURCES
    misc/fonts/Cousine-Regular.ttf
    misc/fonts/DroidSans.ttf
    misc/fonts/Karla-Regular.ttf
    misc/fonts/ProggyClean.ttf
    misc/fonts/ProggyTiny.ttf
    misc/fonts/Roboto-Medium.ttf
)
set(IMGUI_FONTS_SOURCES
    misc/fonts/binary_to_compressed_c.cpp
)

set(IMGUI_FT_PUBLIC
    misc/freetype/imgui_freetype.h
)
set(IMGUI_FT_SOURCES
    misc/freetype/imgui_freetype.cpp
)

set(IMGUI_NATVIS_RESOURCES
    misc/natvis/imgui.natvis
)

file(GLOB IMGUI_INCLUDES_EXAMPLES examples/*.h)
file(GLOB IMGUI_SOURCES_EXAMPLES examples/*.cpp)

install(FILES ${IMGUI_INCLUDES_PUBLIC} ${IMGUI_SOURCES} DESTINATION include)
install(FILES ${IMGUI_CPP_PUBLIC} ${IMGUI_CPP_SOURCES} DESTINATION include/misc/cpp)
install(FILES ${IMGUI_FONTS_SOURCES} ${IMGUI_FONTS_RESOURCES} DESTINATION include/misc/fonts)
install(FILES ${IMGUI_FT_PUBLIC} ${IMGUI_FT_SOURCES} DESTINATION include/misc/freetype)
install(FILES ${IMGUI_NATVIS_RESOURCES} DESTINATION include/misc/natvis)
install(FILES ${IMGUI_INCLUDES_EXAMPLES} ${IMGUI_SOURCES_EXAMPLES} DESTINATION include/examples)
