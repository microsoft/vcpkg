# Lua can be compiled as either C or C++.
# Default configuration is C, set COMPILE_AS_CPP to ON to use C++.
# See http://stackoverflow.com/questions/13560945/c-and-c-library-using-longjmp for why would you want to do that.
# Primary differences:
# - Exceptions will be used instead of setjmp/longjmp
# - The name mangling for functions will be C++ instead of C.
#     - This is a source-incompatible change because extern "C" is chosen by the including application.
# - The lua.hpp header will not be available.

CMAKE_MINIMUM_REQUIRED(VERSION 3.18)

PROJECT(lua)

# Build Libraries
FILE(GLOB HDR_LIBLUA "${CMAKE_SOURCE_DIR}/src/*.h")
# For luac.c
LIST(REMOVE_ITEM HDR_LIBLUA "${CMAKE_SOURCE_DIR}/src/lopnames.h")

FILE(GLOB SRC_LIBLUA "${CMAKE_SOURCE_DIR}/src/*.c")
# Executables luac and luai
LIST(REMOVE_ITEM SRC_LIBLUA "${CMAKE_SOURCE_DIR}/src/luac.c" "${CMAKE_SOURCE_DIR}/src/lua.c")

IF (WIN32)
    # remove warnings
    ADD_DEFINITIONS (-D_CRT_SECURE_NO_WARNINGS )
ENDIF ()

IF (UNIX)
    ADD_DEFINITIONS (-DLUA_USE_POSIX)
    FIND_LIBRARY (LIB_MATH NAMES m)
ENDIF ()

# C library
SET (CMAKE_C_STANDARD 99)
SET(SRC_LIBLUAC ${SRC_LIBLUA})
ADD_LIBRARY ( lua ${SRC_LIBLUAC} ${HDR_LIBLUA} )
TARGET_INCLUDE_DIRECTORIES(lua PRIVATE $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/src> PUBLIC $<INSTALL_INTERFACE:include>)
SET_PROPERTY (TARGET lua PROPERTY POSITION_INDEPENDENT_CODE ON)
SET_SOURCE_FILES_PROPERTIES(${SRC_LIBLUAC} PROPERTIES LANGUAGE C)

IF (BUILD_SHARED_LIBS AND WIN32)
    TARGET_COMPILE_DEFINITIONS (lua PUBLIC -DLUA_BUILD_AS_DLL )
ENDIF ()

IF (UNIX)
    IF (APPLE)
        TARGET_COMPILE_DEFINITIONS (lua PUBLIC -DLUA_USE_DLOPEN)
    ELSE ()
        FIND_LIBRARY (LIB_DLOPEN NAMES dl)
        IF (LIB_DLOPEN)
            TARGET_COMPILE_DEFINITIONS (lua PUBLIC -DLUA_USE_DLOPEN)
            TARGET_LINK_LIBRARIES (lua ${CMAKE_DL_LIBS})
        ENDIF ()
        IF (LIB_MATH)
            TARGET_LINK_LIBRARIES (lua m)
        ENDIF ()
    ENDIF ()
ENDIF ()

INSTALL ( TARGETS lua
    EXPORT unofficial-lua-config
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(EXPORT unofficial-lua-config DESTINATION share/unofficial-lua)

# CXX library
IF (COMPILE_AS_CPP)
    ADD_SUBDIRECTORY(cpp)
ENDIF()

IF (INSTALL_TOOLS)
    # compiler uses non-exported APIs, so must include sources directly.
    ADD_EXECUTABLE ( luac ${CMAKE_SOURCE_DIR}/src/luac.c ${SRC_LIBLUA} ${CMAKE_SOURCE_DIR}/src/lopnames.h )
    ADD_EXECUTABLE ( luai ${CMAKE_SOURCE_DIR}/src/lua.c )  # interpreter

    TARGET_INCLUDE_DIRECTORIES(luac PRIVATE ${CMAKE_CURRENT_LIST_DIR}/src)
    TARGET_LINK_LIBRARIES ( luai PRIVATE lua )
    SET_TARGET_PROPERTIES ( luai PROPERTIES OUTPUT_NAME lua PDB_NAME luai )
    IF (UNIX)
        IF (CMAKE_SYSTEM_NAME STREQUAL FreeBSD)
            SET (_LIB_READLINE_NAME edit)
        ELSE ()
            SET (_LIB_READLINE_NAME readline)
        ENDIF ()
        FIND_LIBRARY (LIB_READLINE NAMES ${_LIB_READLINE_NAME})
        IF (LIB_READLINE)
            TARGET_COMPILE_DEFINITIONS (luai PUBLIC -DLUA_USE_READLINE)
            TARGET_LINK_LIBRARIES(luai PRIVATE ${LIB_READLINE})
            IF (_LIB_READLINE_NAME STREQUAL edit)
                TARGET_INCLUDE_DIRECTORIES (luai PUBLIC /usr/include/edit)
            ENDIF ()
        ENDIF ()
        
        IF (LIB_MATH)
            TARGET_LINK_LIBRARIES (luac m)
        ENDIF ()
    ENDIF ()
    INSTALL ( TARGETS luai luac RUNTIME DESTINATION tools/lua )
ENDIF ()

IF (NOT SKIP_INSTALL_HEADERS)
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
