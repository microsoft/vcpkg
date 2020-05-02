cmake_minimum_required(VERSION 3.0)
project(SDL2_gfx VERSION 1.0.4 LANGUAGES C)

set(CONFIG_NAME "sdl2-gfx")

find_path(SDL_INCLUDE_DIR SDL2/SDL.h)
find_package(SDL2 CONFIG REQUIRED)

# builtin formats
set(SDL_GFX_DEFINES WIN32)
if(BUILD_SHARED_LIBS)
    list(APPEND SDL_GFX_DEFINES DLL_EXPORT)
endif()

add_library(${PROJECT_NAME}
    SDL2_framerate.c
    SDL2_gfxPrimitives.c
    SDL2_imageFilter.c
    SDL2_rotozoom.c)

target_include_directories(${PROJECT_NAME} PUBLIC
    $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}>
    $<INSTALL_INTERFACE:include>
    $<INSTALL_INTERFACE:include/SDL2>
)

if(WIN32)
    add_compile_definitions(${SDL_GFX_DEFINES})
endif()
target_include_directories(${PROJECT_NAME} PRIVATE ${SDL_INCLUDE_DIR}/SDL2)
target_link_libraries(${PROJECT_NAME} PRIVATE SDL2::SDL2)

install(TARGETS ${PROJECT_NAME}
    EXPORT ${PROJECT_NAME}
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

install(EXPORT ${PROJECT_NAME}
    FILE ${CONFIG_NAME}-targets.cmake
    NAMESPACE SDL2::
    DESTINATION share/${CONFIG_NAME}/
)
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${CONFIG_NAME}-config.cmake
"include(CMakeFindDependencyMacro)
find_dependency(SDL2 CONFIG)
include(\${CMAKE_CURRENT_LIST_DIR}/${CONFIG_NAME}-targets.cmake)"
)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${CONFIG_NAME}-config.cmake DESTINATION share/${CONFIG_NAME})

if(NOT SDL_GFX_SKIP_HEADERS)
    install(FILES SDL2_framerate.h SDL2_gfxPrimitives.h SDL2_imageFilter.h SDL2_rotozoom.h SDL2_gfxPrimitives_font.h DESTINATION include/SDL2)
endif()
