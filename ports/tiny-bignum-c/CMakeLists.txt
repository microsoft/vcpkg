cmake_minimum_required(VERSION 3.14)

project(tiny-bignum-c LANGUAGES C)

include(GNUInstallDirs)

add_library(tiny-bignum-c bn.c)

target_include_directories(
    tiny-bignum-c
    PUBLIC
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)
target_compile_definitions(
    tiny-bignum-c
    PRIVATE
        $<$<C_COMPILER_ID:MSVC>:_CRT_SECURE_NO_WARNINGS>
)
set_target_properties(tiny-bignum-c PROPERTIES PUBLIC_HEADER bn.h)

install(TARGETS tiny-bignum-c EXPORT unofficial-tiny-bignum-c-config)

install(
    EXPORT unofficial-tiny-bignum-c-config
    NAMESPACE unofficial::tiny-bignum-c::
    DESTINATION share/unofficial-tiny-bignum-c
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)
