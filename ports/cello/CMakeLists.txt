cmake_minimum_required(VERSION 3.14)

project(cello LANGUAGES C)

include(GNUInstallDirs)

file(GLOB cello_sources src/*.c)
add_library(cello ${cello_sources})

target_include_directories(
    cello
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

set_target_properties(cello PROPERTIES PUBLIC_HEADER include/Cello.h)

install(TARGETS cello EXPORT unofficial-cello-config)

install(
    EXPORT unofficial-cello-config
    NAMESPACE unofficial::cello::
    DESTINATION share/unofficial-cello
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)
