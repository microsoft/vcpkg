cmake_minimum_required(VERSION 3.14)

project(iniparser LANGUAGES C)

include(GNUInstallDirs)

set(CMAKE_DISABLE_SOURCE_CHANGES ON)
set(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

# iniparser.pc
set(prefix ${CMAKE_INSTALL_PREFIX})
set(libdir ${prefix}/${CMAKE_INSTALL_LIBDIR})
set(includedir ${prefix}/${CMAKE_INSTALL_INCLUDEDIR})
set(datarootdir ${prefix}/${CMAKE_INSTALL_DATAROOTDIR})
set(datadir ${prefix}/${CMAKE_INSTALL_DATADIR})

configure_file(iniparser.pc ${CMAKE_CURRENT_BINARY_DIR}/iniparser.pc)

set(iniparser_sources
    src/dictionary.c
    src/iniparser.c
)

add_library(iniparser ${iniparser_sources})

target_include_directories(iniparser
    PUBLIC
        $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/src>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
)

target_compile_definitions(iniparser
    PRIVATE
        $<$<C_COMPILER_ID:MSVC>:_CRT_SECURE_NO_WARNINGS>
)

install(TARGETS iniparser EXPORT unofficial-iniparser-config)

install(
    EXPORT unofficial-iniparser-config
    NAMESPACE unofficial::iniparser::
    DESTINATION share/unofficial-iniparser
    PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ
)

install(
    FILES src/dictionary.h src/iniparser.h
    DESTINATION include
)

install(
    FILES ${CMAKE_CURRENT_BINARY_DIR}/iniparser.pc
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/pkgconfig
)
