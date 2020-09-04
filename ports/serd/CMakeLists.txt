cmake_minimum_required(VERSION 3.17)
project(serd C)

add_library(serd
    src/byte_source.c
    src/env.c
    src/n3.c
    src/node.c
    src/reader.c
    src/string.c
    src/uri.c
    src/writer.c
)

file(WRITE "${CMAKE_BINARY_DIR}/serd_config.h" "")

target_include_directories(serd
    PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_BINARY_DIR}"
)

set_target_properties(serd PROPERTIES
    C_STANDARD 99
    C_STANDARD_REQUIRED ON
)

target_compile_definitions(serd PRIVATE SERD_INTERNAL _CRT_SECURE_NO_WARNINGS)

if(BUILD_SHARED_LIBS)
    target_compile_definitions(serd PUBLIC SERD_SHARED)
endif()

install(
    TARGETS serd
    EXPORT serd-config
    INCLUDES DESTINATION include
)

if(NOT DISABLE_INSTALL_HEADERS)
    install(DIRECTORY serd DESTINATION include)
endif()

install(
    EXPORT serd-config
    NAMESPACE serd::
    DESTINATION "${CMAKE_INSTALL_PREFIX}/share/serd"
)
