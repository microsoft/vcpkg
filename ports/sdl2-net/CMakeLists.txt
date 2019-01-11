cmake_minimum_required(VERSION 3.0)
project(SDL2_NET C)

if (MSVC)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /wd4244 /wd4996")
endif()

find_path(SDL_INCLUDE_DIR SDL2/SDL.h)
find_library(SDL_LIBRARY NAMES SDL2d SDL2)

add_library(SDL2_net SDLnet.c SDLnetselect.c SDLnetTCP.c SDLnetUDP.c version.rc)

set_target_properties(SDL2_net PROPERTIES DEFINE_SYMBOL SDL2_EXPORTS)
target_compile_definitions(SDL2_net PRIVATE _WINSOCK_DEPRECATED_NO_WARNINGS)
target_include_directories(SDL2_net PRIVATE ${SDL_INCLUDE_DIR}/SDL2)
target_link_libraries(SDL2_net ${SDL_LIBRARY} ws2_32 iphlpapi)

install(TARGETS SDL2_net
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

if(NOT DEFINED SDL_NET_SKIP_HEADERS)
    install(FILES SDL_net.h DESTINATION include/SDL2)
endif()

message(STATUS "Link-time dependencies:")
message(STATUS "  " ${SDL_LIBRARY})
