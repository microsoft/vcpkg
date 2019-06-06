cmake_minimum_required(VERSION 3.0)
project(libdatrie LANGUAGES C)

option(SKIP_HEADERS "Skip headers" OFF)
option(SKIP_TOOL "Skip tool" OFF)
option(BUILD_SHARED_LIBS "Build shared libs" OFF)

set(LIB_SRCS
    datrie/alpha-map.c
    datrie/darray.c
    datrie/dstring.c
    datrie/fileutils.c
    datrie/tail.c
    datrie/trie.c
    datrie/trie-string.c
)

set(LIB_HDRS
    datrie/alpha-map.h
    datrie/trie.h
    datrie/triedefs.h
    datrie/typedefs.h
)

if(WIN32)
    list(APPEND LIB_SRCS datrie/libdatrie.def)
endif()

include(CheckIncludeFile)
include(CheckFunctionExists)

set(STDC_HEADERS 1)
check_include_file(dlfcn.h HAVE_DLFCN_H)
check_include_file(inttypes.h HAVE_INTTYPES_H)
check_include_file(limits.h HAVE_LIMITS_H)
check_include_file(memory.h HAVE_MEMORY_H)
check_include_file(stdint.h HAVE_STDINT_H)
check_include_file(stdio.h HAVE_STDIO_H)
check_include_file(stdlib.h HAVE_STDLIB_H)
check_include_file(strings.h HAVE_STRINGS_H)
check_include_file(string.h HAVE_STRING_H)
check_include_file(sys/stat.h HAVE_SYS_STAT_H)
check_include_file(sys/types.h HAVE_SYS_TYPES_H)
check_include_file(unistd.h HAVE_UNISTD_H)

check_function_exists(nl_langinfo HAVE_LANGINFO_CODESET)
check_function_exists(locale_charset HAVE_LOCALE_CHARSET)
check_function_exists(malloc HAVE_MALLOC)

configure_file(config.h.cmake config.h)

add_library(libdatrie ${LIB_SRCS})
target_include_directories(libdatrie PRIVATE ".")
target_include_directories(libdatrie PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
set_target_properties(libdatrie PROPERTIES PREFIX "")
set_target_properties(libdatrie PROPERTIES DEBUG_POSTFIX "d")

if(MSVC)
    add_definitions(-D_CRT_SECURE_NO_WARNINGS)
    add_definitions(-D_CRT_NONSTDC_NO_DEPRECATE)
endif()


if (NOT SKIP_TOOL)
    add_executable(trietool "tools/trietool.c" )
    target_include_directories(trietool PRIVATE ".")
    target_include_directories(trietool PRIVATE ${CMAKE_CURRENT_BINARY_DIR})
    target_link_libraries(trietool libdatrie)

    find_path(ICONV_INCLUDE_DIR iconv.h)
    find_library(ICONV_LIBRARY NAMES iconv libiconv)
    find_library(CHARSET_LIBRARY NAMES charset libcharset)
    target_include_directories(trietool PRIVATE ${ICONV_INCLUDE_DIR})
    target_link_libraries(trietool ${ICONV_LIBRARY} ${CHARSET_LIBRARY})

    install(
        TARGETS trietool
        RUNTIME DESTINATION bin
    )
endif()

install(
  TARGETS libdatrie
  RUNTIME DESTINATION bin
  LIBRARY DESTINATION lib
  ARCHIVE DESTINATION lib
)

if (NOT SKIP_HEADERS)
    install(
        FILES ${LIB_HDRS}
        DESTINATION "include/datrie"
    )
endif()
