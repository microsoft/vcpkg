cmake_minimum_required(VERSION 3.17)
project(sord C)

find_package(serd CONFIG REQUIRED)

add_library(sord
    src/sord.c
    src/syntax.c
)

file(WRITE "${CMAKE_BINARY_DIR}/sord_config.h" "")

target_include_directories(sord
    PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/src" "${CMAKE_BINARY_DIR}"
)

target_link_libraries(sord PUBLIC serd::serd)

set_target_properties(sord PROPERTIES
    C_STANDARD 99
    C_STANDARD_REQUIRED ON
)

target_compile_definitions(sord PRIVATE SORD_INTERNAL _CRT_SECURE_NO_WARNINGS)

if(BUILD_SHARED_LIBS)
    target_compile_definitions(sord PUBLIC SORD_SHARED)
endif()

install(
    TARGETS sord 
    EXPORT sord-targets
    INCLUDES DESTINATION include
)

if(NOT DISABLE_INSTALL_HEADERS)
    install(DIRECTORY sord DESTINATION include)
endif()

install(
    EXPORT sord-targets
    NAMESPACE sord::
    DESTINATION "${CMAKE_INSTALL_PREFIX}/share/sord"
)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/sord-config.cmake" [[
include(CMakeFindDependencyMacro)
find_dependency(serd CONFIG)
include("${CMAKE_CURRENT_LIST_DIR}/sord-targets.cmake")
]])

install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/sord-config.cmake"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/share/sord"
)
