cmake_minimum_required(VERSION 3.17)
project(lilv C)

find_package(lv2 CONFIG REQUIRED)
find_package(serd CONFIG REQUIRED)
find_package(sord CONFIG REQUIRED)
find_package(sratom CONFIG REQUIRED)

add_library(lilv
    src/collections.c
    src/filesystem.c
    src/instance.c
    src/lib.c
    src/node.c
    src/plugin.c
    src/pluginclass.c
    src/port.c
    src/query.c
    src/scalepoint.c
    src/state.c
    src/ui.c
    src/util.c
    src/world.c
    src/zix/tree.c
)

if(CMAKE_SYSTEM_NAME STREQUAL "Windows" OR CMAKE_SYSTEM_NAME STREQUAL "MinGW")
    set(LILV_PATH_SEP [[;]])
    set(LILV_DIR_SEP [[\\]])
    set(LV2_PATH [[%APPDATA%\\LV2;%COMMONPROGRAMFILES%\\LV2]])
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
    set(LILV_PATH_SEP ":")
    set(LILV_DIR_SEP "/")
    set(LV2_PATH "~/Library/Audio/Plug-Ins/LV2:~/.lv2:/usr/local/lib/lv2:/usr/lib/lv2:/Library/Audio/Plug-Ins/LV2")
else()
    set(LILV_PATH_SEP ":")
    set(LILV_DIR_SEP "/")
    set(LV2_PATH "~/.lv2:/usr/lib/lv2:/usr/local/lib/lv2")
endif()

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/lilv_config.h.in" [[
#define LILV_PATH_SEP "@LILV_PATH_SEP@"
#define LILV_DIR_SEP "@LILV_DIR_SEP@"
#define LILV_DEFAULT_LV2_PATH "@LV2_PATH@"
]])
configure_file("${CMAKE_CURRENT_BINARY_DIR}/lilv_config.h.in" "${CMAKE_CURRENT_BINARY_DIR}/lilv_config.h")

target_include_directories(lilv
    PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}" "${CMAKE_CURRENT_SOURCE_DIR}/src" "${CMAKE_CURRENT_BINARY_DIR}"
)

target_link_libraries(lilv
    PUBLIC lv2::lv2
    PRIVATE serd::serd sord::sord sratom::sratom
)

set_target_properties(lilv PROPERTIES
    C_STANDARD 99
    C_STANDARD_REQUIRED ON
)

target_compile_definitions(lilv PRIVATE LILV_INTERNAL _CRT_SECURE_NO_WARNINGS)

if(BUILD_SHARED_LIBS)
    target_compile_definitions(lilv PUBLIC LILV_SHARED)
endif()

install(
    TARGETS lilv 
    EXPORT lilv-targets
    INCLUDES DESTINATION include
)

if(NOT DISABLE_INSTALL_HEADERS)
    install(DIRECTORY lilv DESTINATION include)
endif()

install(
    EXPORT lilv-targets
    NAMESPACE lilv::
    DESTINATION "${CMAKE_INSTALL_PREFIX}/share/lilv"
)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/lilv-config.cmake" [[
include(CMakeFindDependencyMacro)
find_dependency(lv2 CONFIG)
find_dependency(serd CONFIG)
find_dependency(sord CONFIG)
find_dependency(sratom CONFIG)
include("${CMAKE_CURRENT_LIST_DIR}/lilv-targets.cmake")
]])

install(
    FILES "${CMAKE_CURRENT_BINARY_DIR}/lilv-config.cmake"
    DESTINATION "${CMAKE_INSTALL_PREFIX}/share/lilv"
)
