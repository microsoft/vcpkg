cmake_minimum_required(VERSION 3.10)
project(luasocket)

if(WIN32)
    set(PLATFORM_LIBRARIES ws2_32)
endif()

find_path(LUA_INCLUDE_DIR lua.h PATH_SUFFIXES lua)
find_library(LUA_LIBRARY lua)
set(LUASOCKET_INCLUDES ${LUA_INCLUDE_DIR} src)
set(LUASOCKET_LIBRARIES ${LUA_LIBRARY} ${PLATFORM_LIBRARIES})

add_library(socket.core
    src/luasocket.c
    src/timeout.c
    src/buffer.c
    src/io.c
    src/auxiliar.c
    src/options.c
    src/inet.c
    src/except.c
    src/select.c
    src/tcp.c
    src/udp.c
    src/compat.c)
if(WIN32)
    target_sources(socket.core PRIVATE
        src/wsocket.c)
elseif (UNIX)
    target_sources(socket.core PRIVATE
        src/usocket.c)
endif()
set_target_properties(socket.core PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "socket"
    LIBRARY_OUTPUT_DIRECTORY "socket"
    PREFIX ""
    RUNTIME_OUTPUT_NAME "core"
    LIBRARY_OUTPUT_NAME "core")
target_include_directories(socket.core PRIVATE ${LUASOCKET_INCLUDES})
target_link_libraries(socket.core PRIVATE ${LUASOCKET_LIBRARIES})

add_library(mime.core
    src/mime.c
    src/compat.c)
set_target_properties(mime.core PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "mime"
    LIBRARY_OUTPUT_DIRECTORY "mime"
    PREFIX ""
    RUNTIME_OUTPUT_NAME "core"
    LIBRARY_OUTPUT_NAME "core")
target_include_directories(mime.core PRIVATE ${LUASOCKET_INCLUDES})
target_link_libraries(mime.core PRIVATE ${LUASOCKET_LIBRARIES})

if(UNIX)
    add_library(socket.unix
        src/buffer.c
        src/compat.c
        src/auxiliar.c
        src/options.c
        src/timeout.c
        src/io.c
        src/usocket.c
        src/unix.c
        src/unixdgram.c
        src/unixstream.c)
    set_target_properties(socket.unix PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "socket"
        LIBRARY_OUTPUT_DIRECTORY "socket"
        PREFIX ""
        RUNTIME_OUTPUT_NAME "unix"
        LIBRARY_OUTPUT_NAME "unix")
    target_include_directories(socket.unix PRIVATE ${LUASOCKET_INCLUDES})
    target_link_libraries(socket.unix PRIVATE ${LUASOCKET_LIBRARIES})

    add_library(socket.serial
        src/buffer.c
        src/compat.c
        src/auxiliar.c
        src/options.c
        src/timeout.c
        src/io.c
        src/usocket.c
        src/serial.c)
    set_target_properties(socket.serial PROPERTIES
        RUNTIME_OUTPUT_DIRECTORY "socket"
        LIBRARY_OUTPUT_DIRECTORY "socket"
        PREFIX ""
        RUNTIME_OUTPUT_NAME "serial"
        LIBRARY_OUTPUT_NAME "serial")
    target_include_directories(socket.serial PRIVATE ${LUASOCKET_INCLUDES})
    target_link_libraries(socket.serial PRIVATE ${LUASOCKET_LIBRARIES})
endif()

if(WIN32)
    if("${BUILD_TYPE}" STREQUAL "STATIC")
        add_definitions(
            "-DLUASOCKET_API=")
    else()
        add_definitions(
            "-DLUASOCKET_API=__declspec(dllexport)")
    endif()
endif()

install(TARGETS socket.core
    RUNTIME DESTINATION bin/socket
    LIBRARY DESTINATION lib/socket
    ARCHIVE DESTINATION lib)

install(TARGETS mime.core
    RUNTIME DESTINATION bin/mime
    LIBRARY DESTINATION lib/mime
    ARCHIVE DESTINATION lib)

if(UNIX)
    install(TARGETS socket.unix
        RUNTIME DESTINATION bin/socket
        LIBRARY DESTINATION lib/socket
        ARCHIVE DESTINATION lib)
    install(TARGETS socket.serial
        RUNTIME DESTINATION bin/socket
        LIBRARY DESTINATION lib/socket
        ARCHIVE DESTINATION lib)
endif()

install(FILES
    src/ltn12.lua
    src/socket.lua
    src/mime.lua
    DESTINATION share/lua)

install(FILES
    src/http.lua
    src/url.lua
    src/tp.lua
    src/ftp.lua
    src/headers.lua
    src/smtp.lua
    DESTINATION share/lua/socket)
