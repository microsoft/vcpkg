cmake_minimum_required(VERSION 3.13)
project(uWebSockets)

add_library(uWebSockets INTERFACE)

if (CMAKE_USE_OPENSSL)
    find_package(OpenSSL REQUIRED)
    set(USE_OPENSSL "-DUSE_OPENSSL -DLIBUS_USE_OPENSSL")
    list(APPEND CMAKE_REQUIRED_INCLUDES ${OPENSSL_INCLUDE_DIR})
else()
    set(NOT_USE_OPENSSL "-DLIBUS_NO_SSL")
endif()

file(GLOB SOURCES src/*.h)

if (CMAKE_USE_OPENSSL)
    # It requires C++17 or later, see https://github.com/uNetworking/uSockets/blob/0ebdde0601cc82349fc11a7c4bbb6dc5c9f28f42/Makefile#L55
    set(CMAKE_CXX_STANDARD 17)
    find_package(OpenSSL REQUIRED)
    file(GLOB SSL_SOURCES src/crypto/*.c*)
    list(APPEND SOURCES ${SSL_SOURCES})
    list(APPEND UWEBSOCKETS_EXT_LIBS OpenSSL::SSL OpenSSL::Crypto)
endif()

target_include_directories(${PROJECT_NAME} INTERFACE include)

install(FILES ${SOURCES} DESTINATION include)
