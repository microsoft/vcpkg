cmake_minimum_required(VERSION 3.0)
project(lpeg)

if(NOT WIN32)
    message(FATAL_ERROR "Written for windows only")
endif()

find_path(LUA_INCLUDE_DIR lua.h PATH_SUFFIXES lua)
find_library(LUA_LIBRARY lua)
set(LPEG_INCLUDES ${LUA_INCLUDE_DIR})
set(LPEG_LIBRARIES ${LUA_LIBRARY})

add_library(lpeg
    lpvm.c
    lptree.c
    lpprint.c
    lpcap.c
    lpcode.c
    lpeg.def)

target_include_directories(lpeg PRIVATE ${LPEG_INCLUDES})
target_link_libraries(lpeg PRIVATE ${LPEG_LIBRARIES})

install(TARGETS lpeg
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)
install(FILES re.lua DESTINATION share/lua)
