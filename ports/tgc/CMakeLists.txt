cmake_minimum_required(VERSION 3.14)

project(tgc LANGUAGES C)

include(GNUInstallDirs)

add_library(tgc tgc.c)

target_include_directories(
    tgc
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

set_target_properties(tgc PROPERTIES PUBLIC_HEADER tgc.h)

install(TARGETS tgc EXPORT unofficial-tgc-config)

install(
    EXPORT unofficial-tgc-config
    NAMESPACE unofficial::tgc::
    DESTINATION share/unofficial-tgc
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)
