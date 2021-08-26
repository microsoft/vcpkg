cmake_minimum_required(VERSION 3.0)
project(luafilesystem)

find_path(LUA_INCLUDE_DIR lua.h PATH_SUFFIXES lua)
find_library(LUA_LIBRARY lua)
set(LFS_INCLUDES ${LUA_INCLUDE_DIR})
set(LFS_LIBRARIES ${LUA_LIBRARY})

add_library( lfs src/lfs.h src/lfs.c src/lfs.def)

target_include_directories(lfs PRIVATE ${LFS_INCLUDES})
target_link_libraries(lfs PRIVATE ${LFS_LIBRARIES})

install(TARGETS lfs
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)
