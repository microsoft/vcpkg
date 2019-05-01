cmake_minimum_required(VERSION 3.0)
project(SDL2_GFX C)

find_path(SDL_INCLUDE_DIR SDL2/SDL.h)
find_package(SDL2 CONFIG REQUIRED)

# builtin formats
set(SDL_GFX_DEFINES WIN32)
if(BUILD_SHARED_LIBS)
    list(APPEND SDL_GFX_DEFINES DLL_EXPORT)
endif()

add_library(SDL2_gfx 
    SDL2_framerate.c
    SDL2_gfxPrimitives.c
    SDL2_imageFilter.c
    SDL2_rotozoom.c)

target_compile_definitions(SDL2_gfx PRIVATE ${SDL_GFX_DEFINES})
target_include_directories(SDL2_gfx PRIVATE ${SDL_INCLUDE_DIR}/SDL2)
target_link_libraries(SDL2_gfx PRIVATE SDL2::SDL2)

install(TARGETS SDL2_gfx
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

if(NOT SDL_GFX_SKIP_HEADERS)
    install(FILES SDL2_framerate.h SDL2_gfxPrimitives.h SDL2_imageFilter.h SDL2_rotozoom.h SDL2_gfxPrimitives_font.h DESTINATION include/SDL2)
endif()
