cmake_minimum_required(VERSION 3.14)

project(tiny-aes-c LANGUAGES C ASM)

include(GNUInstallDirs)

add_library(tiny-aes-c aes.c)

target_include_directories(
    tiny-aes-c
    PUBLIC
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

install(FILES aes.h aes.hpp DESTINATION include)

install(TARGETS tiny-aes-c EXPORT unofficial-tiny-aes-c-config)

install(
    EXPORT unofficial-tiny-aes-c-config
    NAMESPACE unofficial::tiny-aes-c::
    DESTINATION share/unofficial-tiny-aes-c
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)
