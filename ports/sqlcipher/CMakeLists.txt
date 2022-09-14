cmake_minimum_required(VERSION 3.10)
project(sqlcipher C)

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
option(WITH_COMMONCRYPTO "Use the CommonCrypto encryption backend (Apple only)" OFF)
option(WITH_OPENSSL "Use the OpenSSL encryption backend" OFF)
option(WITH_LIBTOMCRYPT "Use the libtomcrypt encryption backend" OFF)
option(WITH_NSS "Use the nss encryption backend" OFF)

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
add_library(sqlcipher sqlite3.c)

target_compile_definitions(
    sqlcipher
    PUBLIC
        -DSQLITE_HAS_CODEC

    PRIVATE
        $<$<CONFIG:Debug>:SQLITE_DEBUG>
        $<$<CONFIG:Debug>:SQLITE_ENABLE_SELECTTRACE>
        $<$<CONFIG:Debug>:SQLITE_ENABLE_WHERETRACE>
        ${API}
        -DSQLITE_ENABLE_RTREE
        -DSQLITE_ENABLE_UNLOCK_NOTIFY
        -DSQLITE_ENABLE_COLUMN_METADATA
        -DSQLITE_TEMP_STORE=2
)

if (ENABLE_FTS3)
    target_compile_definitions(sqlcipher PUBLIC SQLITE_ENABLE_FTS3)
endif()

if (ENABLE_FTS4)
    target_compile_definitions(sqlcipher PUBLIC SQLITE_ENABLE_FTS4)
endif()

if (ENABLE_FTS5)
    target_compile_definitions(sqlcipher PUBLIC SQLITE_ENABLE_FTS5)
endif()

if (ENABLE_MEMSYS3)
    target_compile_definitions(sqlcipher PUBLIC SQLITE_ENABLE_MEMSYS3)
endif()

if (ENABLE_MEMSYS5)
    target_compile_definitions(sqlcipher PUBLIC SQLITE_ENABLE_MEMSYS5)
endif()

if (ENABLE_MATH_FUNCTION)
    target_compile_definitions(sqlcipher PUBLIC SQLITE_ENABLE_MATH_FUNCTIONS)
endif()

if (ENABLE_LIMIT)
    target_compile_definitions(sqlcipher PUBLIC SQLITE_ENABLE_UPDATE_DELETE_LIMIT)
endif()

if (ENABLE_RTREE)
    target_compile_definitions(sqlcipher PUBLIC SQLITE_ENABLE_RTREE)
endif()

if (ENABLE_SESSION)
    target_compile_definitions(sqlcipher PUBLIC SQLITE_ENABLE_SESSION SQLITE_ENABLE_PREUPDATE_HOOK)
endif()

if (ENABLE_OMIT_LOAD_EXT)
    target_compile_definitions(sqlcipher PUBLIC SQLITE_OMIT_LOAD_EXTENSION)
endif()

if(WITH_GEOPOLY)
    target_compile_definitions(sqlcipher PRIVATE SQLITE_ENABLE_GEOPOLY)
endif()

if(WITH_JSON1)
    target_compile_definitions(sqlcipher PRIVATE SQLITE_ENABLE_JSON1)
endif()

target_include_directories(sqlcipher
    PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_FILE}> $<INSTALL_INTERFACE:include>
)

if(NOT WIN32)
    find_package(Threads REQUIRED)
    target_link_libraries(sqlcipher PRIVATE Threads::Threads ${CMAKE_DL_LIBS})
endif()
if (UNIX AND NOT APPLE)
    target_link_libraries(sqlcipher PRIVATE m)
endif()

if (WITH_ZLIB)
    find_package(ZLIB REQUIRED)
    target_link_libraries(sqlite3 PUBLIC ZLIB::ZLIB)
endif()

if(WITH_OPENSSL)
    find_package(OpenSSL REQUIRED)
    target_link_libraries(sqlcipher PRIVATE OpenSSL::Crypto)
    target_compile_definitions(sqlcipher PRIVATE SQLCIPHER_CRYPTO_OPENSSL)
elseif(WITH_COMMONCRYPTO)
    target_link_libraries(sqlcipher PRIVATE System)
    target_compile_definitions(sqlcipher PRIVATE SQLCIPHER_CRYPTO_CC)
# nss currently doesn't work on Windows
# see https://github.com/microsoft/vcpkg/issues/26760
elseif(WITH_NSS)
    find_library(NSS_LIB nss3 REQUIRED)
    find_path(NSS_INCLUDE_DIR nss/nss.h REQUIRED)
    target_link_libraries(sqlcipher PRIVATE ${NSS_LIB})
    target_include_directories(sqlcipher PRIVATE ${NSS_INCLUDE_DIR})
    target_compile_definitions(sqlcipher PRIVATE SQLCIPHER_CRYPTO_NSS)
elseif(WITH_LIBTOMCRYPT)
    find_library(TOMCRYPT_LIB tomcrypt REQUIRED)
    find_path(TOMCRYPT_INCLUDE_DIR tomcrypt.h REQUIRED)
    target_link_libraries(sqlcipher PRIVATE ${TOMCRYPT_LIB})
    target_include_directories(sqlcipher PRIVATE ${TOMCRYPT_INCLUDE_DIR})
    target_compile_definitions(sqlcipher PRIVATE SQLCIPHER_CRYPTO_LIBTOMCRYPT)
endif()

if(WIN32)
    target_compile_definitions(sqlcipher PRIVATE -DSQLITE_OS_WIN=1)
    if(CMAKE_SYSTEM_NAME MATCHES "WindowsStore")
        target_compile_definitions(sqlcipher PRIVATE -DSQLITE_OS_WINRT=1)
    endif()
else()
    target_compile_definitions(sqlcipher PRIVATE -DSQLITE_OS_UNIX=1)
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

install(
    TARGETS sqlcipher
    EXPORT sqlcipher-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(FILES sqlite3.h sqlite3ext.h DESTINATION include/sqlcipher CONFIGURATIONS Release)
install(EXPORT sqlcipher-targets NAMESPACE sqlcipher:: FILE sqlcipher-targets.cmake DESTINATION share/sqlcipher)
