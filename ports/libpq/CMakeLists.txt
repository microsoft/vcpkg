cmake_minimum_required(VERSION 3.5)
project(libpq VERSION 9.6.1 LANGUAGES C)

if(NOT CMAKE_SYSTEM_PROCESSOR)
    set(CMAKE_SYSTEM_PROCESSOR ${CMAKE_HOST_SYSTEM_PROCESSOR})
endif()

find_package(OpenSSL REQUIRED)
find_program(PERL NAMES perl)

set(CMAKE_STATIC_LIBRARY_PREFIX)
set(CMAKE_SHARED_LIBRARY_PREFIX)
set(CMAKE_DEBUG_POSTFIX "d")

file(REMOVE
    ${CMAKE_CURRENT_SOURCE_DIR}/src/include/pg_config.h
    ${CMAKE_CURRENT_SOURCE_DIR}/src/include/pg_config_ext.h
    ${CMAKE_CURRENT_SOURCE_DIR}/src/include/pg_config_os.h
)

if(WIN32)
    configure_file(src/include/pg_config.h.win32 include/pg_config.h)
    configure_file(src/include/pg_config_ext.h.win32 include/pg_config_ext.h)
    configure_file(src/include/port/win32.h include/pg_config_os.h)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin" AND CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/include/pg_config_ext.h" "#include <stdint.h>\n#define PG_INT64_TYPE int64_t")
    configure_file("${PORT_DIR}/pg_config.darwin.h" include/pg_config.h COPYONLY)
    configure_file(src/include/port/darwin.h include/pg_config_os.h COPYONLY)
    configure_file(src/backend/port/dynloader/darwin.h include/dynloader.h COPYONLY)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux" AND CMAKE_SYSTEM_PROCESSOR STREQUAL "x86_64")
    if("${CMAKE_SIZEOF_VOID_P}" EQUAL "8")
        set(DEFINE_PG_INT128_TYPE "#define PG_INT128_TYPE __int128")
    else()
        set(DEFINE_PG_INT128_TYPE "#undef PG_INT128_TYPE")
    endif()
    file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/include/pg_config_ext.h" "#include <stdint.h>\n#define PG_INT64_TYPE int64_t")
    configure_file(src/include/port/linux.h include/pg_config_os.h COPYONLY)
    configure_file("${PORT_DIR}/pg_config.linux.h" include/pg_config.h)
    configure_file(src/backend/port/dynloader/linux.h include/dynloader.h COPYONLY)
else()
    message(FATAL_ERROR "Unknown system: ${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_PROCESSOR}")
endif()
file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/include/pg_config_paths.h "#define SYSCONFDIR \"\"")

set(INSTALL_INCLUDES ON CACHE BOOL "Install include files")

set(pg_port_src
    src/port/pgstrcasecmp.c
    src/port/pqsignal.c
    src/port/thread.c
    src/port/crypt.c
    src/port/noblock.c
    src/port/chklocale.c
    src/port/snprintf.c
    src/port/dirmod.c
    src/port/pgsleep.c
    src/port/open.c
    src/port/system.c
)
if(WIN32)
    list(APPEND pg_port_src
        src/port/dirent.c
        src/port/inet_aton.c
        src/port/inet_net_ntop.c
        src/port/win32error.c
        src/port/win32setlocale.c
        src/port/getaddrinfo.c
        src/port/strlcpy.c
    )
    include_directories(src/include/port/win32 src/include/port/win32_msvc)
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    list(APPEND pg_port_src
        src/port/strlcpy.c
        src/port/inet_aton.c
        src/port/inet_net_ntop.c
        src/port/getpeereid.c
    )
endif()

set(pg_backend_src
    src/backend/libpq/md5.c
    src/backend/libpq/ip.c
    src/backend/utils/mb/wchar.c
    src/backend/utils/mb/encnames.c
)
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    list(APPEND pg_backend_src
        src/backend/port/dynloader/linux.c
        src/backend/port/sysv_sema.c
        src/backend/port/sysv_shmem.c
    )
endif()
if(NOT WIN32)
    add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/include/utils/errcodes.h
        COMMAND "${PERL}" "${CMAKE_CURRENT_SOURCE_DIR}/src/backend/utils/generate-errcodes.pl" "${CMAKE_CURRENT_SOURCE_DIR}/src/backend/utils/errcodes.txt" > "${CMAKE_CURRENT_BINARY_DIR}/include/utils/errcodes.h"
        VERBATIM
    )
    list(APPEND pg_backend_src
        ${CMAKE_CURRENT_BINARY_DIR}/include/utils/errcodes.h
    )
endif()

set(pg_libpq_src
    src/interfaces/libpq/fe-auth.c
    src/interfaces/libpq/fe-connect.c
    src/interfaces/libpq/fe-exec.c
    src/interfaces/libpq/fe-lobj.c
    src/interfaces/libpq/fe-misc.c
    src/interfaces/libpq/fe-print.c
    src/interfaces/libpq/fe-protocol2.c
    src/interfaces/libpq/fe-protocol3.c
    src/interfaces/libpq/fe-secure-openssl.c
    src/interfaces/libpq/fe-secure.c
    src/interfaces/libpq/libpq-events.c
    src/interfaces/libpq/pqexpbuffer.c
    src/interfaces/libpq/libpq-dist.rc
)

if(WIN32)
    list(APPEND pg_libpq_src
        src/interfaces/libpq/pthread-win32.c
        src/interfaces/libpq/win32.c
    )
endif()
set(pg_libpq_interface
    src/include/postgres_ext.h
    ${CMAKE_CURRENT_BINARY_DIR}/include/pg_config_ext.h
    ${CMAKE_CURRENT_BINARY_DIR}/include/pg_config.h
    src/interfaces/libpq/libpq-fe.h
    src/interfaces/libpq/libpq-events.h
)
set(pg_libpq_catalog_interface
    src/include/catalog/pg_type.h
    src/include/catalog/genbki.h
)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_DEBUG_POSTFIX "d")
set(CMAKE_INCLUDE_CURRENT_DIR ON)
add_library(libpq ${pg_port_src} ${pg_backend_src} ${pg_libpq_src})

target_compile_definitions(libpq PRIVATE -DFRONTEND -DENABLE_THREAD_SAFETY -DUSE_OPENSSL -DHAVE_CRYPTO_LOCK -D_CRT_SECURE_NO_WARNINGS)
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    target_compile_definitions(libpq PRIVATE -D_GNU_SOURCE)
endif()

target_link_libraries(libpq PRIVATE OpenSSL::SSL)
if(WIN32)
    target_link_libraries(libpq PRIVATE ws2_32 secur32 advapi32 shell32 crypt32)
endif()
target_include_directories(libpq PRIVATE src/include src/port ${CMAKE_CURRENT_BINARY_DIR}/include)
set_target_properties(libpq PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)

install(TARGETS libpq
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
)

if(INSTALL_INCLUDES)
    install(FILES ${pg_libpq_interface} DESTINATION include)
    install(DIRECTORY src/include/libpq DESTINATION include)
    install(FILES ${pg_libpq_catalog_interface} DESTINATION include/catalog)
endif()
