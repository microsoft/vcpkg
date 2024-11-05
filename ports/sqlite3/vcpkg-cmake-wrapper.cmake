cmake_policy(PUSH)
cmake_policy(SET CMP0057 NEW) # Support new IN_LIST if() operator

if("MODULE" IN_LIST ARGS)
    _find_package(${ARGS})
    cmake_policy(POP)
    return()
endif()

if("REQUIRED" IN_LIST ARGS)
    set(REQUIRES "REQUIRED")
else()
    set(REQUIRES)
endif()

_find_package(unofficial-sqlite3 CONFIG ${REQUIRES})

if(NOT TARGET unofficial::sqlite3::sqlite3)
    set(SQLite3_FOUND FALSE)
else()
    # Refer to https://gitlab.kitware.com/cmake/cmake/-/blob/v3.30.0/Modules/FindSQLite3.cmake.
    if(POLICY CMP0159)
        cmake_policy(SET CMP0159 NEW) # file(STRINGS) with REGEX updates CMAKE_MATCH_<n>
    endif()

    set(SQLite3_FOUND TRUE)
    get_target_property(SQLite3_INCLUDE_DIRS unofficial::sqlite3::sqlite3 INTERFACE_INCLUDE_DIRECTORIES)
    set(SQLite3_LIBRARIES unofficial::sqlite3::sqlite3)

    # Look for the necessary header
    find_path(SQLite3_INCLUDE_DIR NAMES sqlite3.h
        HINTS ${SQLite3_INCLUDE_DIRS}
    )
    mark_as_advanced(SQLite3_INCLUDE_DIR)
    # Extract version information from the header file
    if(SQLite3_INCLUDE_DIR)
        file(STRINGS ${SQLite3_INCLUDE_DIR}/sqlite3.h _ver_line
            REGEX "^#define SQLITE_VERSION  *\"[0-9]+\\.[0-9]+\\.[0-9]+\""
            LIMIT_COUNT 1)
        string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+"
            SQLite3_VERSION "${_ver_line}")
        unset(_ver_line)
    endif()

    if(NOT TARGET SQLite::SQLite3)
        add_library(SQLite::SQLite3 INTERFACE IMPORTED)
        set_target_properties(SQLite::SQLite3 PROPERTIES INTERFACE_LINK_LIBRARIES unofficial::sqlite3::sqlite3)
    endif()
endif()

cmake_policy(POP)
