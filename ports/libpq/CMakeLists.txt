cmake_minimum_required(VERSION 3.5)
project(libpq VERSION 9.6.1 LANGUAGES C)
#set(CMAKE_DEBUG_POSTFIX "d")
find_package(OpenSSL REQUIRED)
configure_file(${CMAKE_CURRENT_LIST_DIR}/src/include/pg_config.h.win32 ${CMAKE_CURRENT_LIST_DIR}/src/include/pg_config.h)
configure_file(${CMAKE_CURRENT_LIST_DIR}/src/include/pg_config_ext.h.win32 ${CMAKE_CURRENT_LIST_DIR}/src/include/pg_config_ext.h)
configure_file(${CMAKE_CURRENT_LIST_DIR}/src/include/port/win32.h ${CMAKE_CURRENT_LIST_DIR}/src/include/pg_config_os.h)
file(WRITE src/interfaces/libpq/pg_config_paths.h "#define SYSCONFDIR \"\"")
set(INSTALL_INCLUDES ON CACHE BOOL "Install include files")
set(pg_port_src
    src/port/getaddrinfo.c
    src/port/pgstrcasecmp.c
    src/port/pqsignal.c
    src/port/thread.c
    src/port/inet_aton.c
    src/port/crypt.c
    src/port/noblock.c
    src/port/chklocale.c
    src/port/inet_net_ntop.c
    src/port/snprintf.c
    src/port/strlcpy.c
    src/port/dirent.c
    src/port/dirmod.c
    src/port/pgsleep.c
    src/port/open.c
    src/port/system.c
    src/port/win32error.c
    src/port/win32setlocale.c
)
set(pg_backend_src
    src/backend/libpq/md5.c
    src/backend/libpq/ip.c
    src/backend/utils/mb/wchar.c
    src/backend/utils/mb/encnames.c
)
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
    src/interfaces/libpq/pthread-win32.c
    src/interfaces/libpq/win32.c
    src/interfaces/libpq/libpq-dist.rc
)
set(pg_libpq_interface
    src/include/postgres_ext.h
    src/include/pg_config_ext.h
    src/include/pg_config.h
    src/interfaces/libpq/libpq-fe.h
    )
set(pg_libpq_catalog_interface
    src/include/catalog/pg_type.h
    src/include/catalog/genbki.h
)
set(CMAKE_INCLUDE_CURRENT_DIR ON)
add_library(libpq ${pg_port_src} ${pg_backend_src} ${pg_libpq_src})
target_compile_definitions(libpq PRIVATE -DFRONTEND -DENABLE_THREAD_SAFETY -DUSE_OPENSSL -D_CRT_SECURE_NO_WARNINGS)
target_link_libraries(libpq PRIVATE OpenSSL::SSL ws2_32 secur32 advapi32 shell32)
target_include_directories(libpq PRIVATE src/include src/include/port/win32 src/include/port/win32_msvc src/port)
set_target_properties(libpq PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
install(TARGETS libpq
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
    RUNTIME DESTINATION bin
    )
if(INSTALL_INCLUDES)
    install(FILES ${pg_libpq_interface} DESTINATION include)
    install(FILES ${pg_libpq_catalog_interface} DESTINATION include/catalog)
endif()