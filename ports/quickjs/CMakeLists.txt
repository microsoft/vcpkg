cmake_minimum_required(VERSION 3.15)

project(quickjs)

option(ENABLE_BIGNUM "Enable support for Bignum extensions" ON)

if (CMAKE_COMPILER_IS_GNU)
    list(APPEND QUICKJS_COMPILE_OPTIONS -Wall -MMD -MF -Wno-array-bounds -Wno-format-truncation)
elseif (CMAKE_COMPILER_IS_LANG)
    list(APPEND QUICKJS_COMPILE_OPTIONS PRIVATE -Wall -Wextra -Wno-sign-compare -Wno-missing-field-initializers
        -Wundef -Wuninitialized -Wunused -Wno-unused-parameter -Wwrite-strings -Wchar-subscripts -funsigned-char
        -MMD -MF _GNU_SOURCE
    )
endif()

set(QUICKJS_DEFINITIONS "")

if (MSVC)
    list(APPEND QUICKJS_DEFINITIONS __USE_MINGW_ANSI_STDIO _CRT_SECURE_NO_WARNINGS)
endif()

if(ENABLE_BIGNUM)
    list(APPEND QUICKJS_SOURCES libbf.c)
    list(APPEND QUICKJS_DEFINITIONS CONFIG_BIGNUM)
endif()

list(APPEND QUICKJS_SOURCES
    quickjs.c
    libregexp.c
    libunicode.c
    cutils.c
    quickjs-libc.c
)

find_path(DIRENT_INCLUDE_DIRS "dirent.h")

add_library(quickjs ${QUICKJS_SOURCES})

target_include_directories(quickjs PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR};${DIRENT_INCLUDE_DIRS}>
    $<INSTALL_INTERFACE:include>
)

target_compile_definitions(quickjs PUBLIC ${QUICKJS_DEFINITIONS} CONFIG_VERSION=\"2021-03-27\")
target_compile_options(quickjs PRIVATE ${QUICKJS_COMPILE_OPTIONS})

if (UNIX)
    find_package(Threads REQUIRED)
    target_link_libraries(quickjs PRIVATE m dl Threads::Threads)
endif()

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
