cmake_minimum_required(VERSION 3.14)

project(mathc LANGUAGES C)

include(GNUInstallDirs)

add_library(mathc mathc.c)

target_include_directories(
    mathc
    PUBLIC
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

set_target_properties(mathc PROPERTIES PUBLIC_HEADER mathc.h)

install(TARGETS mathc EXPORT unofficial-mathc-config)

install(
    EXPORT unofficial-mathc-config
    NAMESPACE unofficial::mathc::
    DESTINATION share/unofficial-mathc
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)
