
cmake_minimum_required(VERSION 3.28)

project(
    lua-cpp-library
    LANGUAGES CXX
)

set(SRC_LIBLUA_CPP ${SRC_LIBLUA})
set(HDR_LIBLUA_CPP ${HDR_LIBLUA})
set(PUBLIC_HDR_LIBLUA_CPP ${PUBLIC_HDR_LIBLUA})
list(REMOVE_ITEM PUBLIC_HDR_LIBLUA_CPP "${LUA_SOURCE_DIR}/lua.hpp")

add_library(
    lua-cpp
    ${SRC_LIBLUA_CPP}
)

set_target_properties(lua-cpp PROPERTIES OUTPUT_NAME "lua-c++")

target_link_libraries(
    lua-cpp
    ${CMAKE_DL_LIBS}
)

if (NOT SKIP_INSTALL_HEADERS)
    set_target_properties(lua-cpp PROPERTIES PUBLIC_HEADER "${PUBLIC_HDR_LIBLUA_CPP}")
endif()

set_source_files_properties(${SRC_LIBLUA_CPP} PROPERTIES LANGUAGE CXX)
target_include_directories(
    lua-cpp
    PRIVATE $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/../src>
    PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/include>
)

if (BUILD_SHARED_LIBS AND WIN32)
    target_compile_definitions(lua-cpp PUBLIC LUA_BUILD_AS_DLL)
endif()

if (UNIX)
    if (APPLE)
        target_compile_definitions(lua-cpp PUBLIC LUA_USE_DLOPEN)
    else()
        if (NOT CMAKE_DL_LIBS STREQUAL "")
            target_compile_definitions(lua-cpp PUBLIC LUA_USE_DLOPEN)
        endif()
    endif()
endif()

list(APPEND targets_to_export lua-cpp)
set(targets_to_export ${targets_to_export} PARENT_SCOPE)
