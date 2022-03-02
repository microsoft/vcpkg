cmake_minimum_required(VERSION 3.10)

project(sqlite3 C)

option(ENABLE_FTS3 "Enable the FTS3 extension" OFF)
option(ENABLE_FTS4 "Enable the FTS4 extension" OFF)
option(ENABLE_FTS5 "Enable the FTS5 extension" OFF)
option(ENABLE_MEMSYS3 "Enable MEMSYS3" OFF)
option(ENABLE_MEMSYS5 "Enable MEMSYS5" OFF)
option(ENABLE_MATH_FUNCTION "Enable math functions" OFF)
option(ENABLE_LIMIT "Enable the UPDATE/DELETE LIMIT clause" OFF)
option(ENABLE_RTREE "Enable the RTREE extension" OFF)
option(ENABLE_SESSION "Enable the SESSION extension" OFF)
option(ENABLE_OMIT_LOAD_EXT "Enable loading of external extensions" OFF)
option(WITH_GEOPOLY "Enable geopoly functionality for sqlite3" OFF)
option(WITH_JSON1 "Enable JSON functionality for sqlite3" OFF)
option(WITH_ZLIB "Build sqlite3 with zlib support" OFF)
option(SQLITE3_SKIP_TOOLS "Disable build sqlite3 executable" OFF)

if(BUILD_SHARED_LIBS)
    if(UNIX)
        set(SQLITE_API "-DSQLITE_API=__attribute__((visibility(\"default\")))")
    elseif(WIN32)
        set(SQLITE_API "-DSQLITE_API=__declspec(dllexport)")
    else()
        message(FATAL_ERROR "Unsupported platform: ${CMAKE_SYSTEM_NAME}")
    endif()
endif()

add_library(sqlite3 sqlite3.c)

target_include_directories(sqlite3 PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}> $<INSTALL_INTERFACE:include>)

target_compile_definitions(
    sqlite3
    PRIVATE
        $<$<CONFIG:Debug>:SQLITE_DEBUG=1>
        $<$<CONFIG:Debug>:SQLITE_ENABLE_SELECTTRACE>
        $<$<CONFIG:Debug>:SQLITE_ENABLE_WHERETRACE>
        ${SQLITE_API}
        -DSQLITE_ENABLE_UNLOCK_NOTIFY
        -DSQLITE_ENABLE_COLUMN_METADATA
)

if (BUILD_SHARED_LIBS)
    if (UNIX)
        string(APPEND PKGCONFIG_DEFINES " -DSQLITE_API=__attribute__((visibility(\"default\")))")
        target_compile_definitions(sqlite3 INTERFACE "SQLITE_API=__attribute__((visibility(\"default\")))")
    elseif (WIN32)
        string(APPEND PKGCONFIG_DEFINES " -DSQLITE_API=__declspec(dllimport)")
        target_compile_definitions(sqlite3 INTERFACE "SQLITE_API=__declspec(dllimport)")
    endif()
endif()

if (ENABLE_FTS3)
    string(APPEND PKGCONFIG_DEFINES " -DSQLITE_ENABLE_FTS3")
    target_compile_definitions(sqlite3 PUBLIC SQLITE_ENABLE_FTS3)
endif()

if (ENABLE_FTS4)
    string(APPEND PKGCONFIG_DEFINES " -DSQLITE_ENABLE_FTS4")
    target_compile_definitions(sqlite3 PUBLIC SQLITE_ENABLE_FTS4)
endif()

if (ENABLE_FTS5)
    string(APPEND PKGCONFIG_DEFINES " -DSQLITE_ENABLE_FTS5")
    target_compile_definitions(sqlite3 PUBLIC SQLITE_ENABLE_FTS5)
endif()

if (ENABLE_MEMSYS3)
    string(APPEND PKGCONFIG_DEFINES " -DSQLITE_ENABLE_MEMSYS3")
    target_compile_definitions(sqlite3 PUBLIC SQLITE_ENABLE_MEMSYS3)
endif()

if (ENABLE_MEMSYS5)
    string(APPEND PKGCONFIG_DEFINES " -DSQLITE_ENABLE_MEMSYS5")
    target_compile_definitions(sqlite3 PUBLIC SQLITE_ENABLE_MEMSYS5)
endif()

if (ENABLE_MATH_FUNCTION)
    string(APPEND PKGCONFIG_DEFINES " -DSQLITE_ENABLE_MATH_FUNCTIONS")
    target_compile_definitions(sqlite3 PUBLIC SQLITE_ENABLE_MATH_FUNCTIONS)
endif()

if (ENABLE_LIMIT)
    string(APPEND PKGCONFIG_DEFINES " -DSQLITE_ENABLE_UPDATE_DELETE_LIMIT")
    target_compile_definitions(sqlite3 PUBLIC SQLITE_ENABLE_UPDATE_DELETE_LIMIT)
endif()

if (ENABLE_RTREE)
    string(APPEND PKGCONFIG_DEFINES " -DSQLITE_ENABLE_RTREE")
    target_compile_definitions(sqlite3 PUBLIC SQLITE_ENABLE_RTREE)
endif()

if (ENABLE_SESSION)
    string(APPEND PKGCONFIG_DEFINES " -DSQLITE_ENABLE_SESSION -DSQLITE_ENABLE_PREUPDATE_HOOK")
    target_compile_definitions(sqlite3 PUBLIC SQLITE_ENABLE_SESSION SQLITE_ENABLE_PREUPDATE_HOOK)
endif()

if (ENABLE_OMIT_LOAD_EXT)
    string(APPEND PKGCONFIG_DEFINES " -DSQLITE_OMIT_LOAD_EXTENSION")
    target_compile_definitions(sqlite3 PUBLIC SQLITE_OMIT_LOAD_EXTENSION)
endif()

if(WITH_GEOPOLY)
    string(APPEND PKGCONFIG_DEFINES " -DSQLITE_ENABLE_GEOPOLY")
    target_compile_definitions(sqlite3 PUBLIC SQLITE_ENABLE_GEOPOLY)
endif()

if(WITH_JSON1)
    string(APPEND PKGCONFIG_DEFINES " -DSQLITE_ENABLE_JSON1")
    target_compile_definitions(sqlite3 PUBLIC SQLITE_ENABLE_JSON1)
endif()

if (WIN32)
    string(APPEND PKGCONFIG_DEFINES " -DQLITE_OS_WIN=1")
    target_compile_definitions(sqlite3 PUBLIC -DSQLITE_OS_WIN=1)

    if(CMAKE_SYSTEM_NAME MATCHES "WindowsStore")
        string(APPEND PKGCONFIG_DEFINES " -DSQLITE_OS_WINRT=1")
        target_compile_definitions(sqlite3 PUBLIC -DSQLITE_OS_WINRT=1)
    endif()
else()
    string(APPEND PKGCONFIG_DEFINES " -DSQLITE_OS_UNIX=1")
    target_compile_definitions(sqlite3 PUBLIC -DSQLITE_OS_UNIX=1)
endif()

if(NOT WIN32)
    find_package(Threads REQUIRED)
    target_link_libraries(sqlite3 PUBLIC Threads::Threads ${CMAKE_DL_LIBS})
endif()

if (WITH_ZLIB)
    find_package(ZLIB REQUIRED)
    target_link_libraries(sqlite3 PUBLIC ZLIB::ZLIB)
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
    set(PKGCONFIG_LIBS_PRIVATE "-lm -ldl")
    if(NOT ANDROID)
        string(APPEND PKGCONFIG_LIBS_PRIVATE " -lpthread")
    endif()
else()
    set(PKGCONFIG_LIBS_PRIVATE "")
endif()

configure_file(sqlite3.pc.in sqlite3.pc @ONLY)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/sqlite3.pc" DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig")
