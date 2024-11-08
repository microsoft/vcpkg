cmake_policy(PUSH)
cmake_policy(SET CMP0057 NEW) # Support new IN_LIST if() operator

if("MODULE" IN_LIST ARGS)
    _find_package(${ARGS})
    cmake_policy(POP)
    return()
endif()

list(APPEND z_vcpkg_find_package_${z_vcpkg_find_package_backup_id}_backup_vars "CMAKE_MODULE_PATH")
if(DEFINED CMAKE_MODULE_PATH)
    set(z_vcpkg_find_package_${z_vcpkg_find_package_backup_id}_backup_CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}")
endif()
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}")

_find_package(${ARGS})
if(NOT Z_VCPKG_FIND_PACKAGE_DUMMY_SQLite3_FOUND)
    cmake_policy(POP)
    return()
endif()
unset(Z_VCPKG_FIND_PACKAGE_DUMMY_SQLite3_FOUND)

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
