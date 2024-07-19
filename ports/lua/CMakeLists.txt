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

set(HDR_LIBLUA
        src/lapi.h
        src/lauxlib.h
        src/lcode.h
        src/lctype.h
        src/ldebug.h
        src/ldo.h
        src/lfunc.h
        src/lgc.h
        src/llex.h
        src/llimits.h
        src/lmem.h
        src/lobject.h
        src/lopcodes.h
        src/lparser.h
        src/lstate.h
        src/lstring.h
        src/ltable.h
        src/ltm.h
        src/lua.h
        src/luaconf.h
        src/lualib.h
        src/lundump.h
        src/lvm.h
        src/lzio.h
)

set(PUBLIC_HDR_LIBLUA
        src/lualib.h
        src/lua.h
        src/luaconf.h
        src/lauxlib.h
        src/lua.hpp
)

set(SRC_LIBLUA
        src/lapi.c
        src/lauxlib.c
        src/lbaselib.c
        src/lbitlib.c
        src/lcode.c
        src/lcorolib.c
        src/lctype.c
        src/ldblib.c
        src/ldebug.c
        src/ldo.c
        src/ldump.c
        src/lfunc.c
        src/lgc.c
        src/linit.c
        src/liolib.c
        src/llex.c
        src/lmathlib.c
        src/lmem.c
        src/loadlib.c
        src/lobject.c
        src/lopcodes.c
        src/loslib.c
        src/lparser.c
        src/lstate.c
        src/lstring.c
        src/lstrlib.c
        src/ltable.c
        src/ltablib.c
        src/ltm.c
        src/lundump.c
        src/lutf8lib.c
        src/lvm.c
        src/lzio.c
)

set_source_files_properties(${SRC_LIBLUA} PROPERTIES LANGUAGE C)

add_library(
        lua
        ${SRC_LIBLUA}
)

if (NOT SKIP_INSTALL_HEADERS)
    set_target_properties(lua PROPERTIES PUBLIC_HEADER "${PUBLIC_HDR_LIBLUA}")
endif()

target_include_directories(
    lua
    PRIVATE $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/src>
    PUBLIC $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/include>
)

set_target_properties(
    lua
    PROPERTIES
    POSITION_INDEPENDENT_CODE ON
)

target_link_libraries(
    lua
    ${CMAKE_DL_LIBS}
)

# Windows specific section
if (BUILD_SHARED_LIBS AND WIN32)
    target_compile_definitions(lua PUBLIC LUA_BUILD_AS_DLL)
endif()

if (WIN32)
    target_compile_definitions(lua PUBLIC _CRT_SECURE_NO_WARNINGS)
endif()

# Unix specific section
if (UNIX)
    target_compile_definitions(lua PUBLIC LUA_USE_POSIX)
    # math library
    find_library(LIB_MATH NAMES m)
    if (LIB_MATH)
        target_link_libraries(lua m)
    endif()
    # dlopen library
    if (APPLE)
        target_compile_definitions(lua PUBLIC LUA_USE_DLOPEN)
    else()
        if (NOT CMAKE_DL_LIBS STREQUAL "")
            target_compile_definitions(lua PUBLIC LUA_USE_DLOPEN)
        endif()
    endif()
endif()

if (INSTALL_TOOLS AND NOT SKIP_INSTALL_TOOLS)

    # compiler uses non-exported APIs, so must include sources directly.
    add_executable(
            luac
            src/luac.c
            ${SRC_LIBLUA}
    )
    add_executable(unofficial::lua::lua-compiler ALIAS luac)

    if (LIB_MATH)
        target_link_libraries(luac m)
    endif()

    # interpreter
    add_executable(
        luai
        src/lua.c
    )
    add_executable(unofficial::lua::lua-interpreter ALIAS luai)

    target_link_libraries(
        luai
        lua
    )

    set_target_properties(
        luai
        PROPERTIES
        OUTPUT_NAME lua
        PDB_NAME luai
    )

    if (UNIX)
        if (CMAKE_SYSTEM_NAME STREQUAL FreeBSD)
            set(_LIB_READLINE_NAME edit)
        else ()
            set(_LIB_READLINE_NAME readline)
        endif()
        find_library(LIB_READLINE NAMES ${_LIB_READLINE_NAME})
        if (LIB_READLINE)
            target_compile_definitions(luai PUBLIC LUA_USE_READLINE)
            target_link_libraries(luai ${LIB_READLINE})
            if (_LIB_READLINE_NAME STREQUAL edit)
                target_include_directories(luai PUBLIC /usr/include/edit)
            endif()
        endif()
    endif()

    install(
        TARGETS luai luac
        RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/tools/lua
    )

endif()

set(targets_to_export lua)
if (COMPILE_AS_CPP)
    add_subdirectory(cpp)
endif()

install(
    TARGETS ${targets_to_export}
    EXPORT unofficial-lua-config
    RUNTIME         DESTINATION "${CMAKE_INSTALL_PREFIX}/bin"
    LIBRARY         DESTINATION "${CMAKE_INSTALL_PREFIX}/lib"
    ARCHIVE         DESTINATION "${CMAKE_INSTALL_PREFIX}/lib"
    PUBLIC_HEADER   DESTINATION "${CMAKE_INSTALL_PREFIX}/include"
)

install(
    EXPORT unofficial-lua-config
    NAMESPACE unofficial::lua::
    DESTINATION "${CMAKE_INSTALL_PREFIX}/share/unofficial-lua"
)

# append headers to sources to make them show up in MSVC GUI
list(APPEND SRC_LIBLUA ${HDR_LIBLUA})
