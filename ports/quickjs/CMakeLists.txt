cmake_minimum_required(VERSION 3.15)

project(quickjs)

option(ENABLE_BIGNUM "Enable support for Bignum extensions" ON)

add_library(quickjs
    quickjs.c
    libregexp.c
    libunicode.c
    cutils.c
    quickjs-libc.c
)

target_include_directories(quickjs PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}>
    $<INSTALL_INTERFACE:include>
)

if(WIN32)
    target_compile_definitions(quickjs PRIVATE __USE_MINGW_ANSI_STDIO)
else()
    target_compile_definitions(quickjs PRIVATE _GNU_SOURCE)
endif()

if(ENABLE_BIGNUM)
    target_sources(quickjs PRIVATE libbf.c)
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

install(TARGETS quickjs
    EXPORT unofficial-quickjs-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(FILES quickjs.h quickjs-libc.h
    DESTINATION include
    CONFIGURATIONS Release
)

install(EXPORT unofficial-quickjs-targets
    NAMESPACE unofficial::quickjs::
    FILE unofficial-quickjs-targets.cmake
    DESTINATION share/unofficial-quickjs
)
