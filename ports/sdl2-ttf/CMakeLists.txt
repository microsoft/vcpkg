cmake_minimum_required(VERSION 3.0)
project(SDL2_TTF C)

find_path(SDL_INCLUDE_DIR SDL2/SDL.h)
find_package(SDL2 CONFIG REQUIRED)
find_package(Freetype REQUIRED)

add_library(SDL2_ttf SDL_ttf.c version.rc)

set_target_properties(SDL2_ttf PROPERTIES DEFINE_SYMBOL DLL_EXPORT)
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

set(prefix "")
set(exec_prefix [[${prefix}]])
set(libdir [[${prefix}/lib]])
set(includedir [[${prefix}/include]])
set(PACKAGE "SDL2_ttf")
file(READ "SDL_ttf.h" header_contents)
#    #define SDL_TTF_MAJOR_VERSION 2
#    #define SDL_TTF_MINOR_VERSION 0
#    #define SDL_TTF_PATCHLEVEL    5
string(REGEX MATCH "define *SDL_TTF_MAJOR_VERSION *([0-9]+)" _ "${header_contents}")
set(VERSION ${CMAKE_MATCH_1})
string(REGEX MATCH "define *SDL_TTF_MINOR_VERSION *([0-9]+)" _ "${header_contents}")
string(APPEND VERSION ".${CMAKE_MATCH_1}")
string(REGEX MATCH "define *SDL_TTF_PATCHLEVEL *([0-9]+)" _ "${header_contents}")
string(APPEND VERSION ".${CMAKE_MATCH_1}")
set(SDL_VERSION 0.0)
configure_file(SDL2_ttf.pc.in "${CMAKE_CURRENT_BINARY_DIR}/SDL2_ttf.pc" @ONLY)
file(APPEND "${CMAKE_CURRENT_BINARY_DIR}/SDL2_ttf.pc" "Requires.private: freetype2")
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/SDL2_ttf.pc DESTINATION lib/pkgconfig)

if(NOT DEFINED SDL_TTF_SKIP_HEADERS)
    install(FILES SDL_ttf.h DESTINATION include/SDL2)
endif()

message(STATUS "Link-time dependencies:")
message(STATUS "  " SDL2::SDL2)
message(STATUS "  " ${FREETYPE_LIBRARIES})
