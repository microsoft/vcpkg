cmake_minimum_required(VERSION 3.20.0)
project(luasec)

find_path(LUA_INCLUDE_DIR lua.h PATH_SUFFIXES lua)
find_library(LUA_LIBRARY lua)
find_package(OpenSSL)

set(LUASEC_INCLUDES ${LUA_INCLUDE_DIR} src)
set(LUASEC_LIBRARIES
    ${LUA_LIBRARY}
    OpenSSL::SSL
    OpenSSL::Crypto
    OpenSSL::applink
    ws2_32)

add_library(lua-ssl
    src/config.c
    src/ssl.c
    src/context.c
    src/x509.c
    src/ec.c
    src/options.c
    src/luasocket/buffer.c
    src/luasocket/io.c
    src/luasocket/timeout.c
    src/luasocket/wsocket.c)

target_include_directories(lua-ssl PRIVATE ${LUASEC_INCLUDES})
target_link_libraries(lua-ssl PRIVATE ${LUASEC_LIBRARIES})
set_target_properties(lua-ssl PROPERTIES PREFIX "")

install(TARGETS lua-ssl
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib)

install(FILES src/ssl.lua DESTINATION share/lua)
install(FILES src/https.lua DESTINATION share/lua/ssl)
