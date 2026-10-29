cmake_minimum_required(VERSION 3.14)

project(tiny-regex-c LANGUAGES C)

include(GNUInstallDirs)

add_library(tiny-regex-c re.c)

target_include_directories(
    tiny-regex-c
    PUBLIC
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

set_target_properties(tiny-regex-c PROPERTIES PUBLIC_HEADER re.h)

install(TARGETS tiny-regex-c EXPORT unofficial-tiny-regex-c-config)

install(
    EXPORT unofficial-tiny-regex-c-config
    NAMESPACE unofficial::tiny-regex-c::
    DESTINATION share/unofficial-tiny-regex-c
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)
