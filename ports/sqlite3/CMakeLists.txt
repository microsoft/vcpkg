cmake_minimum_required(VERSION 3.10)
project(sqlite3 C)

include_directories(.)
if(BUILD_SHARED_LIBS)
    if(CMAKE_SYSTEM_NAME MATCHES "Linux" OR CMAKE_SYSTEM_NAME MATCHES "Darwin")
        set(API "-DSQLITE_API=__attribute__((visibility(\"default\")))")
    elseif(CMAKE_SYSTEM_NAME MATCHES "Windows")
        set(API "-DSQLITE_API=__declspec(dllexport)")
    else()
        message(FATAL_ERROR "Unsupported platform: ${CMAKE_SYSTEM_NAME}")
    endif()
else()
    set(API "-DSQLITE_API=extern")
endif()
add_library(sqlite3 sqlite3.c)

target_compile_definitions(
    sqlite3
    PRIVATE
        $<$<CONFIG:Debug>:SQLITE_DEBUG>
        ${API}
        -DSQLITE_ENABLE_RTREE
        -DSQLITE_ENABLE_UNLOCK_NOTIFY
        -DSQLITE_ENABLE_COLUMN_METADATA
)
target_include_directories(sqlite3 INTERFACE $<INSTALL_INTERFACE:include>)
if(NOT WIN32)
    find_package(Threads REQUIRED)
    target_link_libraries(sqlite3 PRIVATE Threads::Threads ${CMAKE_DL_LIBS})
endif()

if(CMAKE_SYSTEM_NAME MATCHES "WindowsStore")
    target_compile_definitions(sqlite3 PRIVATE -DSQLITE_OS_WINRT=1)
endif()

if(NOT SQLITE3_SKIP_TOOLS)
    add_executable(sqlite3-bin shell.c)
    target_link_libraries(sqlite3-bin PRIVATE sqlite3)
    install(TARGETS sqlite3-bin sqlite3
      RUNTIME DESTINATION tools
      LIBRARY DESTINATION lib
      ARCHIVE DESTINATION lib
    )
endif()

install(
    TARGETS sqlite3
    EXPORT sqlite3
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(FILES sqlite3.h sqlite3ext.h DESTINATION include CONFIGURATIONS Release)
install(EXPORT sqlite3 FILE sqlite3-targets.cmake DESTINATION share/sqlite3)
