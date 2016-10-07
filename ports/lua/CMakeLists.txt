PROJECT ( lua )

IF( NOT WIN32 )
    message( FATAL_ERROR "Written for window only" )
ENDIF()

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

# remove warnings
ADD_DEFINITIONS(-D_CRT_SECURE_NO_WARNINGS ) 

SET (HDR_LIBLUA
src/lapi.h src/lauxlib.h src/lcode.h src/lctype.h src/ldebug.h src/ldo.h src/lfunc.h
src/lgc.h src/llex.h src/llimits.h src/lmem.h src/lobject.h src/lopcodes.h src/lparser.h
src/lstate.h src/lstring.h src/ltable.h src/ltm.h src/lua.h src/luaconf.h src/lualib.h
src/lundump.h src/lvm.h src/lzio.h
)

#SET_SOURCE_FILES_PROPERTIES(${HDR_LIBLUA} PROPERTIES HEADER_FILE_ONLY TRUE)
#include_directories(src)

# Build Libraries
SET (SRC_LIBLUA
src/lapi.c src/lauxlib.c src/lbaselib.c src/lbitlib.c src/lcode.c src/lcorolib.c
src/lctype.c src/ldblib.c src/ldebug.c src/ldo.c src/ldump.c src/lfunc.c src/lgc.c
src/linit.c src/liolib.c src/llex.c src/lmathlib.c src/lmem.c src/loadlib.c src/lobject.c
src/lopcodes.c src/loslib.c src/lparser.c src/lstate.c src/lstring.c src/lstrlib.c
src/ltable.c src/ltablib.c src/ltm.c src/lundump.c src/lutf8lib.c src/lvm.c src/lzio.c
)

SET ( SRC_LUA src/lua.c )

# append headers to sources to make them show up in MSVC GUI
LIST(APPEND SRC_LIBLUA ${HDR_LIBLUA})

#DLL
ADD_LIBRARY ( lua53 SHARED ${SRC_LIBLUA} ${SRC_LUA} )
SET_TARGET_PROPERTIES (lua53 PROPERTIES DEFINE_SYMBOL  "LUA_BUILD_AS_DLL" )

INSTALL ( TARGETS lua53 DESTINATION ${CMAKE_INSTALL_PREFIX}/lib )
INSTALL(DIRECTORY src/ DESTINATION include
            FILES_MATCHING PATTERN lualib.h PATTERN luaconf.h
			PATTERN lua.hpp PATTERN lua.h PATTERN lauxlib.h)