cmake_minimum_required(VERSION 3.0)
project(sqlite3 C)

include_directories(.)
if(BUILD_SHARED_LIBS)
    set(API "-DSQLITE_API=__declspec(dllexport)")
else()
    set(API "-DSQLITE_API=extern")
endif()
add_library(sqlite3 sqlite3.c)

target_compile_definitions(sqlite3 PRIVATE
    $<$<CONFIG:Debug>:SQLITE_DEBUG>
    ${API}
    -DSQLITE_ENABLE_RTREE
    -DSQLITE_ENABLE_UNLOCK_NOTIFY
    )
target_include_directories(sqlite3 INTERFACE $<INSTALL_INTERFACE:include>)

if(CMAKE_SYSTEM_NAME MATCHES "WindowsStore")
    target_compile_definitions(sqlite3 PRIVATE -DSQLITE_OS_WINRT=1)
endif()

if(NOT SQLITE3_SKIP_TOOLS)
    add_executable(sqlite3-bin shell.c)
    set_target_properties(sqlite3-bin PROPERTIES OUTPUT_NAME sqlite3)
    target_link_libraries(sqlite3-bin PRIVATE sqlite3)
    install(TARGETS sqlite3-bin sqlite3
      RUNTIME DESTINATION tools
      LIBRARY DESTINATION lib
      ARCHIVE DESTINATION lib
    )
endif()

install(TARGETS sqlite3 EXPORT sqlite3Config
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(FILES sqlite3.h sqlite3ext.h DESTINATION include CONFIGURATIONS Release)
install(EXPORT sqlite3Config DESTINATION share/sqlite3)
