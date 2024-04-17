cmake_minimum_required(VERSION 3.17)
project(sratom C)

find_package(lv2 CONFIG REQUIRED)
find_package(serd CONFIG REQUIRED)
find_package(sord CONFIG REQUIRED)

add_library(sratom
    src/sratom.c
)

target_include_directories(sratom PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/include" "${CMAKE_CURRENT_SOURCE_DIR}")

target_link_libraries(sratom PUBLIC lv2::lv2 serd::serd sord::sord)

set_target_properties(sratom PROPERTIES
    C_STANDARD 99
    C_STANDARD_REQUIRED ON
)

target_compile_definitions(sratom PRIVATE SRATOM_INTERNAL _CRT_SECURE_NO_WARNINGS)

if(BUILD_SHARED_LIBS)
    target_compile_definitions(sratom PUBLIC SRATOM_SHARED)
endif()

install(
    TARGETS sratom 
    EXPORT sratom-targets
    INCLUDES DESTINATION include
)

if(NOT DISABLE_INSTALL_HEADERS)
    install(DIRECTORY include/sratom DESTINATION include)
endif()

install(
    EXPORT sratom-targets
    NAMESPACE sratom::
    DESTINATION "${CMAKE_INSTALL_PREFIX}/share/sratom"
)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/sratom-config.cmake" [[
include(CMakeFindDependencyMacro)
find_dependency(lv2 CONFIG)
find_dependency(serd CONFIG)
find_dependency(sord CONFIG)
include("${CMAKE_CURRENT_LIST_DIR}/sratom-targets.cmake")
]])

install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/sratom-config.cmake"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/share/sratom"
)
