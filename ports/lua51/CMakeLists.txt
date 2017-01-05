PROJECT ( lua51 )

IF( NOT WIN32 )
    message( FATAL_ERROR "Written for window only" )
ENDIF()

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

SET (HDR_LIBLUA
    src/lapi.h
    src/lauxlib.h
    src/lcode.h
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

# Build Libraries
SET (SRC_LIBLUA
    src/lapi.c
    src/lauxlib.c
    src/lbaselib.c
    src/lcode.c
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
    src/lvm.c
    src/lzio.c
)

# append headers to sources to make them show up in MSVC GUI
LIST(APPEND SRC_LIBLUA ${HDR_LIBLUA})

# remove warnings
ADD_DEFINITIONS (-D_CRT_SECURE_NO_WARNINGS )

#DLL
ADD_LIBRARY ( lua51 ${SRC_LIBLUA} )

IF (BUILD_SHARED_LIBS)
    TARGET_COMPILE_DEFINITIONS (lua51 PRIVATE -DLUA_BUILD_AS_DLL )
ENDIF ()

INSTALL ( TARGETS lua51
    RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
    LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
    ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
)

IF (NOT DEFINED SKIP_INSTALL_TOOLS)
    ADD_EXECUTABLE ( luac src/luac.c src/print.c ${SRC_LIBLUA} ) # compiler
    ADD_EXECUTABLE ( lua src/lua.c ${SRC_LIBLUA} )  # interpreter
    INSTALL ( TARGETS lua luac RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/tools )
ENDIF ()

IF (NOT DEFINED SKIP_INSTALL_HEADERS)
    INSTALL(
        FILES
            src/lualib.h
            src/lua.h
            src/luaconf.h
            src/lauxlib.h
            etc/lua.hpp
        DESTINATION include
    )
ENDIF ()
