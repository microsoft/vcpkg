cmake_minimum_required(VERSION 3.0)
project(SDL2_TTF C)

find_path(SDL_INCLUDE_DIR SDL2/SDL.h)
find_package(SDL2 CONFIG REQUIRED)
find_package(Freetype REQUIRED)

add_library(SDL2_ttf SDL_ttf.c version.rc)

set_target_properties(SDL2_ttf PROPERTIES DEFINE_SYMBOL SDL2_EXPORTS)
target_include_directories(SDL2_ttf PRIVATE ${SDL_INCLUDE_DIR}/SDL2 ${FREETYPE_INCLUDE_DIRS})
target_link_libraries(SDL2_ttf SDL2::SDL2 ${FREETYPE_LIBRARIES})

install(TARGETS SDL2_ttf
    EXPORT SDL2_ttf
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

INSTALL(EXPORT SDL2_ttf
    DESTINATION "share/sdl2-ttf"
    FILE sdl2-ttf-config.cmake
    NAMESPACE SDL2::
)

if(NOT DEFINED SDL_TTF_SKIP_HEADERS)
    install(FILES SDL_ttf.h DESTINATION include/SDL2)
endif()

message(STATUS "Link-time dependencies:")
message(STATUS "  " SDL2::SDL2)
message(STATUS "  " ${FREETYPE_LIBRARIES})
