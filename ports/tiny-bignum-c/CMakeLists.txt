cmake_minimum_required(VERSION 3.14)

project(tiny-bignum-c LANGUAGES C)

include(GNUInstallDirs)

add_library(tiny-bignum-c bn.c)

target_include_directories(
    tiny-bignum-c
    PUBLIC
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

set_target_properties(tiny-bignum-c PROPERTIES PUBLIC_HEADER bn.h)

install(TARGETS tiny-bignum-c EXPORT unofficial-tiny-bignum-c-config)

install(
    EXPORT unofficial-tiny-bignum-c-config
    NAMESPACE unofficial::tiny-bignum-c::
    DESTINATION share/unofficial-tiny-bignum-c
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)
