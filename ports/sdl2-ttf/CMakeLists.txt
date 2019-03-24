cmake_minimum_required(VERSION 3.0)
project(SDL2_TTF C)

find_package(SDL2 CONFIG REQUIRED)
find_package(Freetype REQUIRED)

add_library(SDL2_ttf SDL_ttf.c version.rc)

set_target_properties(SDL2_ttf PROPERTIES DEFINE_SYMBOL SDL2_EXPORTS)
target_link_libraries(SDL2_ttf SDL2::SDL2main Freetype::Freetype)

install(TARGETS SDL2_ttf
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

if(NOT DEFINED SDL_TTF_SKIP_HEADERS)
    install(FILES SDL_ttf.h DESTINATION include/SDL2)
endif()
