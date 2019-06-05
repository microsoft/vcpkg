cmake_minimum_required(VERSION 3.0)
project(SDL1_NET C)

if (MSVC)
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /wd4244 /wd4996")
endif()

find_package(SDL)

add_library(SDL_net SDLnet.c SDLnetselect.c SDLnetTCP.c SDLnetUDP.c version.rc)

set_target_properties(SDL_net PROPERTIES DEFINE_SYMBOL SDL1_EXPORTS)
target_compile_definitions(SDL_net PRIVATE _WINSOCK_DEPRECATED_NO_WARNINGS)
target_include_directories(SDL_net PRIVATE ${SDL_INCLUDE_DIR})
target_link_libraries(SDL_net ${SDL_LIBRARY} ws2_32 iphlpapi)

install(TARGETS SDL_net
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib)

if(NOT DEFINED SDL_NET_SKIP_HEADERS)
    install(FILES SDL_net.h DESTINATION include)
endif()

message(STATUS "Link-time dependencies:")
message(STATUS "  " ${SDL_LIBRARY})
