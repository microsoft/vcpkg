cmake_minimum_required(VERSION 3.0.2)
project(luasocket)

if(NOT WIN32)
    message(FATAL_ERROR "Written for windows only")
endif()

find_path(LUA_INCLUDE_DIR lua.h PATH_SUFFIXES lua)
find_library(LUA_LIBRARY lua)
set(LUASOCKET_INCLUDES ${LUA_INCLUDE_DIR} src)
set(LUASOCKET_LIBRARIES ${LUA_LIBRARY} ws2_32)

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
    src/compat.c
    src/wsocket.c)

add_library(mime.core
    src/mime.c
    src/compat.c)

target_include_directories(socket.core PRIVATE ${LUASOCKET_INCLUDES})
target_link_libraries(socket.core PRIVATE ${LUASOCKET_LIBRARIES})

target_include_directories(mime.core PRIVATE ${LUASOCKET_INCLUDES})
target_link_libraries(mime.core PRIVATE ${LUASOCKET_LIBRARIES})

add_definitions(
    "-DLUASOCKET_API=__declspec(dllexport)"
    "-DMIME_API=__declspec(dllexport)")

install(TARGETS socket.core
    RUNTIME DESTINATION bin/socket
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)

install(TARGETS mime.core
    RUNTIME DESTINATION bin/mime
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)

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
