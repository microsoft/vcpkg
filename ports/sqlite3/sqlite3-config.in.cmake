
if(NOT WIN32)
    include(CMakeFindDependencyMacro)
    find_dependency(Threads)
endif()

include(${CMAKE_CURRENT_LIST_DIR}/sqlite3-targets.cmake)

# Refer to https://gitlab.kitware.com/cmake/cmake/-/blob/v3.30.0/Modules/FindSQLite3.cmake.
cmake_policy(PUSH)
if(POLICY CMP0159)
    cmake_policy(SET CMP0159 NEW) # file(STRINGS) with REGEX updates CMAKE_MATCH_<n>
endif()

get_target_property(SQLite3_INCLUDE_DIRS SQLite::SQLite3 INTERFACE_INCLUDE_DIRECTORIES)
set(SQLite3_LIBRARIES SQLite::SQLite3)

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

cmake_policy(POP)
