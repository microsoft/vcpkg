cmake_minimum_required(VERSION 3.0)
project(SDL2_NET C)

if (MSVC)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /wd4244 /wd4996")
endif()

find_path(SDL_INCLUDE_DIR SDL2/SDL.h)
find_package(SDL2 CONFIG REQUIRED)

add_library(SDL2_net SDLnet.c SDLnetselect.c SDLnetTCP.c SDLnetUDP.c version.rc)

set_target_properties(SDL2_net PROPERTIES DEFINE_SYMBOL DLL_EXPORT)
target_compile_definitions(SDL2_net PRIVATE _WINSOCK_DEPRECATED_NO_WARNINGS)
target_include_directories(SDL2_net PRIVATE ${SDL_INCLUDE_DIR}/SDL2)

if (WIN32)
    target_link_libraries(SDL2_net SDL2::SDL2 ws2_32 iphlpapi)
endif()

install(TARGETS SDL2_net
    EXPORT SDL2_net
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

install(EXPORT SDL2_net
    DESTINATION "share/sdl2-net"
    FILE sdl2-net-config.cmake
    NAMESPACE SDL2::
)

if(NOT DEFINED SDL_NET_SKIP_HEADERS)
    install(FILES SDL_net.h DESTINATION include/SDL2)
endif()

message(STATUS "Link-time dependencies:")
message(STATUS "  " SDL2::SDL2)
