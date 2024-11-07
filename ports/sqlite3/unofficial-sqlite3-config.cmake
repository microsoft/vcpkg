include(${CMAKE_CURRENT_LIST_DIR}/../sqlite3/sqlite3-config.cmake)

if(NOT TARGET unofficial::sqlite3::sqlite3 AND CMAKE_VERSION VERSION_GREATER_EQUAL 3.18)
    add_library(unofficial::sqlite3::sqlite3 ALIAS SQLite::SQLite3)
endif()
