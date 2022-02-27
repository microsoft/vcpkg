cmake_minimum_required(VERSION 3.15)

project(quickjs)

include(GNUInstallDirs)

option(ENABLE_BIGNUM "Enable support for Bignum extensions" ON)

set(PUBLIC_HEADERS
    "${CMAKE_CURRENT_LIST_DIR}/quickjs.h"
    "${CMAKE_CURRENT_LIST_DIR}/quickjs-libc.h"
)

add_library(quickjs
    "${CMAKE_CURRENT_LIST_DIR}/quickjs.c"
    "${CMAKE_CURRENT_LIST_DIR}/libregexp.c"
    "${CMAKE_CURRENT_LIST_DIR}/libunicode.c"
    "${CMAKE_CURRENT_LIST_DIR}/cutils.c"
    "${CMAKE_CURRENT_LIST_DIR}/quickjs-libc.c"
    ${PUBLIC_HEADERS}
)

target_include_directories(quickjs PRIVATE "${CMAKE_CURRENT_LIST_DIR}")

if(WIN32)
    target_compile_definitions(quickjs PRIVATE __USE_MINGW_ANSI_STDIO)
else()
    target_compile_definitions(quickjs PRIVATE _GNU_SOURCE)
endif()

if(ENABLE_BIGNUM)
    target_sources(quickjs PRIVATE
        "${CMAKE_CURRENT_LIST_DIR}/libbf.c"
    )
    target_compile_definitions(quickjs PUBLIC CONFIG_BIGNUM)
endif()

find_package(Threads)
if(Threads_FOUND)
    target_link_libraries(quickjs PUBLIC Threads::Threads)
endif()

# -DCONFIG_VERSION=\"$(shell cat VERSION)\"
target_compile_definitions(quickjs PRIVATE
    CONFIG_VERSION=\"2021-03-27\"
)

set_target_properties(quickjs PROPERTIES PUBLIC_HEADER
    "${PUBLIC_HEADERS}"
)

install(TARGETS quickjs
    EXPORT quickjs
    ARCHIVE DESTINATION "lib"
    LIBRARY DESTINATION "lib"
    PUBLIC_HEADER DESTINATION "include/quickjs"
)

set(CMAKE_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/quickjs)

install(EXPORT quickjs
    FILE quickjs-targets.cmake
    NAMESPACE quickjs::
    DESTINATION ${CMAKE_DESTINATION}
)

export(PACKAGE quickjs)

install(FILES "quickjs-config.cmake" DESTINATION ${CMAKE_DESTINATION})
