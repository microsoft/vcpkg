# Lua can be compiled as both C and C++.
# Default configuration is C, set COMPILE_AS_CPP to ON to use C++.
# See http://stackoverflow.com/questions/13560945/c-and-c-library-using-longjmp for why would you want to do that.
# Primary differences:
# - Exceptions will be used instead of setjmp/longjmp

cmake_minimum_required(VERSION 3.28)

project(
    lua-c-library
    LANGUAGES C
)

set(CMAKE_C_STANDARD 99)

set(LUA_SOURCE_DIR "${CMAKE_SOURCE_DIR}/src/")

set(HDR_LIBLUA
    "${LUA_SOURCE_DIR}/lapi.h"
    "${LUA_SOURCE_DIR}/lauxlib.h"
    "${LUA_SOURCE_DIR}/lcode.h"
    "${LUA_SOURCE_DIR}/lctype.h"
    "${LUA_SOURCE_DIR}/ldebug.h"
    "${LUA_SOURCE_DIR}/ldo.h"
    "${LUA_SOURCE_DIR}/lfunc.h"
    "${LUA_SOURCE_DIR}/lgc.h"
    "${LUA_SOURCE_DIR}/llex.h"
    "${LUA_SOURCE_DIR}/llimits.h"
    "${LUA_SOURCE_DIR}/lmem.h"
    "${LUA_SOURCE_DIR}/lobject.h"
    "${LUA_SOURCE_DIR}/lopcodes.h"
    "${LUA_SOURCE_DIR}/lparser.h"
    "${LUA_SOURCE_DIR}/lstate.h"
    "${LUA_SOURCE_DIR}/lstring.h"
    "${LUA_SOURCE_DIR}/ltable.h"
    "${LUA_SOURCE_DIR}/ltm.h"
    "${LUA_SOURCE_DIR}/lua.h"
    "${LUA_SOURCE_DIR}/luaconf.h"
    "${LUA_SOURCE_DIR}/lualib.h"
    "${LUA_SOURCE_DIR}/lundump.h"
    "${LUA_SOURCE_DIR}/lvm.h"
    "${LUA_SOURCE_DIR}/lzio.h"
)

set(PUBLIC_HDR_LIBLUA
    "${LUA_SOURCE_DIR}/lualib.h"
    "${LUA_SOURCE_DIR}/lua.h"
    "${LUA_SOURCE_DIR}/luaconf.h"
    "${LUA_SOURCE_DIR}/lauxlib.h"
    "${LUA_SOURCE_DIR}/lua.hpp"
)

set(SRC_LIBLUA
    "${LUA_SOURCE_DIR}/lapi.c"
    "${LUA_SOURCE_DIR}/lauxlib.c"
    "${LUA_SOURCE_DIR}/lbaselib.c"
    "${LUA_SOURCE_DIR}/lbitlib.c"
    "${LUA_SOURCE_DIR}/lcode.c"
    "${LUA_SOURCE_DIR}/lcorolib.c"
    "${LUA_SOURCE_DIR}/lctype.c"
    "${LUA_SOURCE_DIR}/ldblib.c"
    "${LUA_SOURCE_DIR}/ldebug.c"
    "${LUA_SOURCE_DIR}/ldo.c"
    "${LUA_SOURCE_DIR}/ldump.c"
    "${LUA_SOURCE_DIR}/lfunc.c"
    "${LUA_SOURCE_DIR}/lgc.c"
    "${LUA_SOURCE_DIR}/linit.c"
    "${LUA_SOURCE_DIR}/liolib.c"
    "${LUA_SOURCE_DIR}/llex.c"
    "${LUA_SOURCE_DIR}/lmathlib.c"
    "${LUA_SOURCE_DIR}/lmem.c"
    "${LUA_SOURCE_DIR}/loadlib.c"
    "${LUA_SOURCE_DIR}/lobject.c"
    "${LUA_SOURCE_DIR}/lopcodes.c"
    "${LUA_SOURCE_DIR}/loslib.c"
    "${LUA_SOURCE_DIR}/lparser.c"
    "${LUA_SOURCE_DIR}/lstate.c"
    "${LUA_SOURCE_DIR}/lstring.c"
    "${LUA_SOURCE_DIR}/lstrlib.c"
    "${LUA_SOURCE_DIR}/ltable.c"
    "${LUA_SOURCE_DIR}/ltablib.c"
    "${LUA_SOURCE_DIR}/ltm.c"
    "${LUA_SOURCE_DIR}/lundump.c"
    "${LUA_SOURCE_DIR}/lutf8lib.c"
    "${LUA_SOURCE_DIR}/lvm.c"
    "${LUA_SOURCE_DIR}/lzio.c"
)

add_library(lua ${SRC_LIBLUA})

set_target_properties(
    lua
    PROPERTIES
    PUBLIC_HEADER "${PUBLIC_HDR_LIBLUA}"
    POSITION_INDEPENDENT_CODE ON
)

target_include_directories(
    lua
    PRIVATE $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/src>
    PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/include>
)

if (WIN32)
    target_compile_definitions(lua PUBLIC _CRT_SECURE_NO_WARNINGS)
    if (BUILD_SHARED_LIBS)
        target_compile_definitions(lua PUBLIC LUA_BUILD_AS_DLL)
    endif()
endif()

if (UNIX)
    target_compile_definitions(lua PUBLIC LUA_USE_POSIX)
    # math library
    find_library(LIB_MATH NAMES m)
    if (LIB_MATH)
        target_link_libraries(lua PRIVATE m)
    endif()
    # dlopen library
    if (APPLE OR NOT CMAKE_DL_LIBS STREQUAL "")
        target_compile_definitions(lua PUBLIC LUA_USE_DLOPEN)
        target_link_libraries(lua PRIVATE ${CMAKE_DL_LIBS})
    endif()
endif()

if (INSTALL_TOOLS)

    # compiler uses non-exported APIs, so must include sources directly.
    add_executable(
        lua-compiler
        src/luac.c
        ${SRC_LIBLUA}
    )

    set_target_properties(
        lua-compiler
        PROPERTIES
        OUTPUT_NAME luac
    )

    if (LIB_MATH)
        target_link_libraries(lua-compiler PRIVATE m)
    endif()

    # interpreter
    add_executable(
        lua-interpreter
        src/lua.c
    )

    target_link_libraries(
        lua-interpreter
        PRIVATE
        lua
    )

    set_target_properties(
        lua-interpreter
        PROPERTIES
        OUTPUT_NAME lua
        PDB_NAME luai
    )

    if (UNIX)
        if (CMAKE_SYSTEM_NAME STREQUAL "FreeBSD")
            set(_LIB_READLINE_NAME edit)
        else ()
            set(_LIB_READLINE_NAME readline)
        endif()
        find_library(LIB_READLINE NAMES ${_LIB_READLINE_NAME})
        if (LIB_READLINE)
            target_compile_definitions(lua-interpreter PUBLIC LUA_USE_READLINE)
            target_link_libraries(lua-interpreter ${LIB_READLINE})
            if (_LIB_READLINE_NAME STREQUAL "edit")
                target_include_directories(lua-interpreter PUBLIC /usr/include/edit)
            endif()
        endif()
    endif()

    install(
        TARGETS lua-interpreter lua-compiler
        EXPORT unofficial-lua-targets
        RUNTIME DESTINATION "tools/lua"
    )

endif()

set(targets_to_export lua)
if (COMPILE_AS_CPP)
    add_subdirectory(cpp)
endif()

install(
    TARGETS ${targets_to_export}
    EXPORT unofficial-lua-targets
    RUNTIME         DESTINATION "bin"
    LIBRARY         DESTINATION "lib"
    ARCHIVE         DESTINATION "lib"
    INCLUDES        DESTINATION "include"
    PUBLIC_HEADER   DESTINATION "include"
)

install(
    EXPORT unofficial-lua-targets
    FILE unofficial-lua-targets.cmake
    NAMESPACE unofficial::lua::
    DESTINATION "share/unofficial-lua"
)

include(CMakePackageConfigHelpers)
write_basic_package_version_file(
    "unofficial-lua-config-version.cmake"
    VERSION ${LUA_RELEASE_VERSION}
    COMPATIBILITY SameMinorVersion
)

file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/unofficial-lua-config.cmake.in"
    "\@PACKAGE_INIT\@\n\n \
    include(\${CMAKE_CURRENT_LIST_DIR}/unofficial-lua-targets.cmake)\n"
)

configure_package_config_file(
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-lua-config.cmake.in"
    "${CMAKE_CURRENT_BINARY_DIR}/unofficial-lua-config.cmake"
    INSTALL_DESTINATION "share/unofficial-lua"
)

install(
    FILES
        "${CMAKE_CURRENT_BINARY_DIR}/unofficial-lua-config-version.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/unofficial-lua-config.cmake"
    DESTINATION "share/unofficial-lua"
)

# append headers to sources to make them show up in MSVC GUI
list(APPEND SRC_LIBLUA ${HDR_LIBLUA})
