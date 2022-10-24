cmake_minimum_required(VERSION 3.13)
project(uSockets C CXX)

option(INSTALL_HEADERS "Install header files" ON)

if (CMAKE_USE_OPENSSL)
    find_package(OpenSSL REQUIRED)
    set(USE_OPENSSL "-DUSE_OPENSSL -DLIBUS_USE_OPENSSL")
    #set(OPENSSL_LIB "OpenSSL::SSL OpenSSL::Crypto")
    list(APPEND CMAKE_REQUIRED_INCLUDES ${OPENSSL_INCLUDE_DIR})
else()
    set(NOT_USE_OPENSSL "-DLIBUS_NO_SSL")
endif()

find_package(libuv CONFIG REQUIRED)
if (TARGET uv)
    set(LIBUV_LIBRARY uv)
else()
    set(LIBUV_LIBRARY uv_a)
endif()

file(GLOB SOURCES src/*.c src/eventing/*.c)

set(USOCKETS_EXT_INCLUDE_DIR )
set(USOCKETS_EXT_LIBS )

if (CMAKE_USE_OPENSSL)
    # It requires C++17 or later, see https://github.com/uNetworking/uSockets/blob/0ebdde0601cc82349fc11a7c4bbb6dc5c9f28f42/Makefile#L55
    set(CMAKE_CXX_STANDARD 17)
    find_package(OpenSSL REQUIRED)
    file(GLOB SSL_SOURCES src/crypto/*.c*)
    list(APPEND SOURCES ${SSL_SOURCES})
    list(APPEND USOCKETS_EXT_LIBS OpenSSL::SSL OpenSSL::Crypto)
endif()

if (CMAKE_USE_EVENT)
    file(GLOB SSL_SOURCES src/eventing/*.c)
    list(APPEND SOURCES ${SSL_SOURCES})
    list(APPEND USOCKETS_EXT_INCLUDE_DIR src/internal/eventing)
endif()

if (CMAKE_USE_NETWORK)
    list(APPEND USOCKETS_EXT_INCLUDE_DIR src/internal/networking)
    list(APPEND USOCKETS_EXT_LIBS ws2_32)
endif()

add_library(uSockets ${SOURCES})

if (${LIBUS_USE_LIBUV})
  target_compile_definitions(uSockets PRIVATE -DLIBUS_USE_LIBUV)
endif()

target_compile_definitions(uSockets PRIVATE ${NOT_USE_OPENSSL} ${USE_OPENSSL})
target_include_directories(uSockets PUBLIC ${OPENSSL_INCLUDE_DIR} ${USOCKETS_EXT_INCLUDE_DIR} PRIVATE "${CMAKE_CURRENT_LIST_DIR}/src")
target_link_libraries(uSockets PUBLIC ${OPENSSL_LIBRARIES} ${LIBUV_LIBRARY} ${USOCKETS_EXT_LIBS})

install(TARGETS uSockets
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

if(INSTALL_HEADERS)
    file(GLOB HEADERS src/*.h)
    install(FILES ${HEADERS} DESTINATION include)
    file(GLOB HEADERS src/interfaces/*.h)
    install(FILES ${HEADERS} DESTINATION include/interfaces)
endif()
