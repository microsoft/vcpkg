cmake_minimum_required(VERSION 3.10)
project(sqlite3 C)

include_directories(.)
if(BUILD_SHARED_LIBS)
    if(UNIX)
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

if(WITH_GEOPOLY)
    add_compile_definitions(SQLITE_ENABLE_GEOPOLY)
endif()

if(WITH_JSON1)
    add_compile_definitions(SQLITE_ENABLE_JSON1)
endif()

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
    EXPORT unofficial-sqlite3-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(FILES sqlite3.h sqlite3ext.h DESTINATION include CONFIGURATIONS Release)
install(EXPORT unofficial-sqlite3-targets NAMESPACE unofficial::sqlite3:: FILE unofficial-sqlite3-targets.cmake DESTINATION share/unofficial-sqlite3)

if(UNIX)
    set(PKGCONFIG_LIBS_PRIVATE "-lm -ldl -lpthread")
else()
    set(PKGCONFIG_LIBS_PRIVATE "")
endif()
configure_file(sqlite3.pc.in sqlite3.pc @ONLY)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/sqlite3.pc" DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig")
