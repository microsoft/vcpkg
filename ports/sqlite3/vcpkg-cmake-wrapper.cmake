find_package(unofficial-sqlite3 CONFIG)
if(TARGET unofficial::sqlite3::sqlite3)
    set(SQLite3_LIBRARY unofficial::sqlite3::sqlite3)
    if(NOT TARGET SQLite::SQLite3)
        add_library(SQLite::SQLite3 INTERFACE IMPORTED)
        set_target_properties(SQLite::SQLite3 PROPERTIES
            INTERFACE_LINK_LIBRARIES unofficial::sqlite3::sqlite3
        )
    endif()
endif()

_find_package(${ARGS})
