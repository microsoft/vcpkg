cmake_minimum_required(VERSION 3.0)
project(sqlite3 C)

include_directories(${SOURCE})
if(BUILD_SHARED_LIBS)
    set(API "-DSQLITE_API=__declspec(dllexport)")
else()
    set(API "-DSQLITE_API=extern")
endif()
add_library(sqlite3 ${SOURCE}/sqlite3.c)


target_compile_definitions(sqlite3 PRIVATE 
    $<$<CONFIG:Debug>:-DSQLITE_DEBUG>
    ${API}
    -DSQLITE_ENABLE_RTREE
    -DSQLITE_ENABLE_UNLOCK_NOTIFY
    )
target_include_directories(sqlite3 INTERFACE $<INSTALL_INTERFACE>:include>)
if(TRIPLET_SYSTEM_NAME MATCHES "WindowsStore")
    target_compile_definitions(sqlite3 PRIVATE -DSQLITE_OS_WINRT=1)
endif()

install(TARGETS sqlite3 EXPORT sqlite3Config    
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)
install(FILES ${SOURCE}/sqlite3.h ${SOURCE}/sqlite3ext.h DESTINATION include CONFIGURATIONS Release)
install(EXPORT sqlite3Config DESTINATION share/sqlite3)