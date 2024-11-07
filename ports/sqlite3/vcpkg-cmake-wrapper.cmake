cmake_policy(PUSH)
cmake_policy(SET CMP0057 NEW) # Support new IN_LIST if() operator

if("MODULE" IN_LIST ARGS)
    _find_package(${ARGS})
    cmake_policy(POP)
    return()
endif()

list(REMOVE_AT ARGS 0)
list(REMOVE_ITEM ARGS "CONFIG" "NO_MODULE")
_find_package(unofficial-sqlite3 ${ARGS} CONFIG)

if(NOT TARGET unofficial::sqlite3::sqlite3)
    set(SQLite3_FOUND FALSE)
else()
    set(SQLite3_FOUND TRUE)
    get_target_property(SQLite3_INCLUDE_DIRS unofficial::sqlite3::sqlite3 INTERFACE_INCLUDE_DIRECTORIES)
    set(SQLite3_LIBRARIES unofficial::sqlite3::sqlite3)
    set(SQLite3_VERSION ${unofficial-sqlite3_VERSION})

    if(NOT TARGET SQLite::SQLite3)
        add_library(SQLite::SQLite3 INTERFACE IMPORTED)
        set_target_properties(SQLite::SQLite3 PROPERTIES INTERFACE_LINK_LIBRARIES unofficial::sqlite3::sqlite3)
    endif()
endif()

cmake_policy(POP)
