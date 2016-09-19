cmake_minimum_required(VERSION 3.0)
project(sqlite3 C)

include_directories(${SOURCE})
add_library(sqlite3 SHARED ${SOURCE}/sqlite3.c)
target_compile_definitions(sqlite3 PRIVATE $<$<CONFIG:Debug>:-DSQLITE_DEBUG> "-DSQLITE_API=__declspec(dllexport)")
if(TRIPLET_SYSTEM_NAME MATCHES "WindowsStore")
    target_compile_definitions(sqlite3 PRIVATE -DSQLITE_OS_WINRT=1)
endif()

install(TARGETS sqlite3
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
install(FILES ${SOURCE}/sqlite3.h ${SOURCE}/sqlite3ext.h DESTINATION include CONFIGURATIONS Release)
