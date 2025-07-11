cmake_minimum_required(VERSION 3.10)
project(sqlcipher C)

find_package(OpenSSL REQUIRED)
if(BUILD_SHARED_LIBS)
    if(UNIX)
        set(API "-DSQLITE_API=__attribute__((visibility(\"default\")))")
    elseif(CMAKE_SYSTEM_NAME MATCHES "Windows")
        set(API "-DSQLITE_API=__declspec(dllexport)")
    else()
        message(FATAL_ERROR "Unsupported platform: ${CMAKE_SYSTEM_NAME}")
    endif()
endif()
add_library(sqlcipher sqlite3.c)

target_compile_definitions(
    sqlcipher
    PRIVATE
        $<$<CONFIG:Debug>:SQLITE_DEBUG>
        ${API}
        -DSQLITE_ENABLE_RTREE
        -DSQLITE_ENABLE_UNLOCK_NOTIFY
        -DSQLITE_ENABLE_COLUMN_METADATA
		-DSQLITE_HAS_CODEC
		-DSQLITE_TEMP_STORE=2
)

if(WITH_GEOPOLY)
    add_compile_definitions(SQLITE_ENABLE_GEOPOLY)
endif()

if(WITH_JSON1)
    add_compile_definitions(SQLITE_ENABLE_JSON1)
endif()

if(WITH_FTS5)
    add_compile_definitions(SQLITE_ENABLE_FTS5)
endif()

target_include_directories(sqlcipher INTERFACE $<INSTALL_INTERFACE:include>)
if(NOT WIN32)
    find_package(Threads REQUIRED)
    target_link_libraries(sqlcipher PRIVATE Threads::Threads ${CMAKE_DL_LIBS})
endif()
if (UNIX AND NOT APPLE)
    target_link_libraries(sqlcipher PRIVATE m)
endif()

target_link_libraries(sqlcipher PRIVATE OpenSSL::Crypto)

if(CMAKE_SYSTEM_NAME MATCHES "WindowsStore")
    target_compile_definitions(sqlcipher PRIVATE -DSQLITE_OS_WINRT=1)
endif()

if(NOT SQLITE3_SKIP_TOOLS)
    add_executable(sqlcipher-bin shell.c)
    target_link_libraries(sqlcipher-bin PRIVATE sqlcipher)
    install(TARGETS sqlcipher-bin sqlcipher
      RUNTIME DESTINATION tools/sqlcipher
      LIBRARY DESTINATION lib
      ARCHIVE DESTINATION lib
    )
endif()

SET(prefix "${CMAKE_INSTALL_PREFIX}")
SET(exec_prefix "\${prefix}")
SET(libdir "\${exec_prefix}/${CMAKE_INSTALL_LIBDIR}")
SET(includedir "\${prefix}/include")
SET(PACKAGE_VERSION ${SQLCIPHER_VERSION})
configure_file("${CMAKE_CURRENT_SOURCE_DIR}/sqlcipher.pc.in" "${CMAKE_CURRENT_BINARY_DIR}/sqlcipher.pc" @ONLY)
install(FILES "${CMAKE_CURRENT_BINARY_DIR}/sqlcipher.pc" DESTINATION "${CMAKE_INSTALL_LIBDIR}/pkgconfig")

install(
    TARGETS sqlcipher
    EXPORT sqlcipher-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(FILES sqlite3.h sqlite3ext.h DESTINATION include/sqlcipher CONFIGURATIONS Release)
install(EXPORT sqlcipher-targets NAMESPACE sqlcipher:: FILE sqlcipher-targets.cmake DESTINATION share/sqlcipher)
