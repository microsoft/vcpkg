cmake_minimum_required(VERSION 3.5)

project(libu2f-server C)

file(GLOB_RECURSE LIBU2F_SERVER_HEADERS u2f-server/*.h)
file(GLOB_RECURSE LIBU2F_SERVER_SOURCE u2f-server/*.c)

add_library(libu2f-server ${LIBU2F_SERVER_SOURCE})

target_include_directories(libu2f-server PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> $<INSTALL_INTERFACE:include>) 
target_compile_definitions(libu2f-server PRIVATE _CRT_SECURE_NO_WARNINGS _CRT_NONSTDC_NO_DEPRECATE)
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} /wd4996")

find_package(json-c CONFIG REQUIRED)
find_package(OpenSSL REQUIRED)
target_link_libraries(libu2f-server PRIVATE OpenSSL::SSL OpenSSL::Crypto json-c::json-c)

install(TARGETS libu2f-server
    EXPORT libu2f-serverConfig
    RUNTIME DESTINATION "bin"
    ARCHIVE DESTINATION "lib"
    LIBRARY DESTINATION "lib"
)

INSTALL(FILES ${LIBU2F_SERVER_HEADERS} DESTINATION "include/libu2f-server")

install(EXPORT libu2f-serverConfig
  FILE libu2f-serverConfig.cmake
  NAMESPACE libu2f-server::
  DESTINATION "share/libu2f-server"
)