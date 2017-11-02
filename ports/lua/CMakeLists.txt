# Lua can be compiled as either C or C++.
# Default configuration is C, set COMPILE_AS_CPP to ON to use C++.
# See http://stackoverflow.com/questions/13560945/c-and-c-library-using-longjmp for why would you want to do that.
# Primary differences:
# - Exceptions will be used instead of setjmp/longjmp
# - The name mangling for functions will be C++ instead of C.
#     - This is a source-incompatible change because extern "C" is chosen by the including application.
# - The lua.hpp header will not be available.

PROJECT ( lua )

IF( NOT WIN32 )
    message( FATAL_ERROR "Written for window only" )
ENDIF()

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

SET (HDR_LIBLUA
src/lapi.h src/lauxlib.h src/lcode.h src/lctype.h src/ldebug.h src/ldo.h src/lfunc.h
src/lgc.h src/llex.h src/llimits.h src/lmem.h src/lobject.h src/lopcodes.h src/lparser.h
src/lstate.h src/lstring.h src/ltable.h src/ltm.h src/lua.h src/luaconf.h src/lualib.h
src/lundump.h src/lvm.h src/lzio.h
)

# Build Libraries
SET (SRC_LIBLUA
src/lapi.c src/lauxlib.c src/lbaselib.c src/lbitlib.c src/lcode.c src/lcorolib.c
src/lctype.c src/ldblib.c src/ldebug.c src/ldo.c src/ldump.c src/lfunc.c src/lgc.c
src/linit.c src/liolib.c src/llex.c src/lmathlib.c src/lmem.c src/loadlib.c src/lobject.c
src/lopcodes.c src/loslib.c src/lparser.c src/lstate.c src/lstring.c src/lstrlib.c
src/ltable.c src/ltablib.c src/ltm.c src/lundump.c src/lutf8lib.c src/lvm.c src/lzio.c
)

IF (COMPILE_AS_CPP)
    SET_SOURCE_FILES_PROPERTIES(${SRC_LIBLUA} src/lua.c src/luac.c PROPERTIES LANGUAGE CXX)
ENDIF ()

# append headers to sources to make them show up in MSVC GUI
LIST(APPEND SRC_LIBLUA ${HDR_LIBLUA})

# remove warnings
ADD_DEFINITIONS (-D_CRT_SECURE_NO_WARNINGS )

#DLL
ADD_LIBRARY ( lua ${SRC_LIBLUA} )

IF (BUILD_SHARED_LIBS)
    TARGET_COMPILE_DEFINITIONS (lua PUBLIC -DLUA_BUILD_AS_DLL )
ENDIF ()

INSTALL ( TARGETS lua
    RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
    LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
    ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
)

IF (NOT DEFINED SKIP_INSTALL_TOOLS)
    ADD_EXECUTABLE ( luac src/luac.c ${SRC_LIBLUA} ) # compiler uses non-exported APIs, so must include sources directly.
    ADD_EXECUTABLE ( luai src/lua.c )  # interpreter
    TARGET_LINK_LIBRARIES ( luai lua )
    SET_TARGET_PROPERTIES ( luai PROPERTIES OUTPUT_NAME lua PDB_NAME luai )
    INSTALL ( TARGETS luai luac RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/tools/lua )
ENDIF ()

IF (NOT DEFINED SKIP_INSTALL_HEADERS)
    INSTALL(
        FILES
            src/lualib.h
            src/lua.h
            src/luaconf.h
            src/lauxlib.h
        DESTINATION include
    )
    # If using C++, don't install extern "C" wrapper.
    IF (NOT COMPILE_AS_CPP)
        INSTALL(FILES src/lua.hpp DESTINATION include)
    ENDIF ()
ENDIF ()
