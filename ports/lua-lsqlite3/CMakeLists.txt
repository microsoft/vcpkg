project( lua-lsqlite3 )

cmake_minimum_required(VERSION 2.8)

# find lua
find_path(Luajit_INCLUDE_DIR NAMES lua.hpp PATH_SUFFIXES luajit-2.0 luajit-2.1)
set(Luajit_LIBRARY "optimized;${CMAKE_PREFIX_PATH}/lib/lua51.lib;debug;${CMAKE_PREFIX_PATH}/debug/lib/lua51.lib")
set(Sqlite3_LIBRARY "optimized;${CMAKE_PREFIX_PATH}/lib/sqlite3.lib;debug;${CMAKE_PREFIX_PATH}/debug/lib/sqlite3.lib")

include_directories(${Luajit_INCLUDE_DIR})
add_definitions( 
    -D_CRT_SECURE_NO_WARNINGS
    -DLUA_BUILD_AS_DLL
    -DLUA_LIB
)

add_library(lsqlite3 MODULE lsqlite3.c)
set_target_properties(lsqlite3 PROPERTIES PREFIX "")
set_target_properties(lsqlite3 PROPERTIES SUFFIX ".so")
target_link_libraries(lsqlite3 
    PRIVATE ${Luajit_LIBRARY}
    PRIVATE ${Sqlite3_LIBRARY}
)

install(TARGETS lsqlite3
    RUNTIME DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
    LIBRARY DESTINATION ${CMAKE_INSTALL_PREFIX}/bin
    ARCHIVE DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
)
