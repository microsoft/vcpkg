cmake_minimum_required(VERSION 3.8)
project(secp256k1 C)

option(INSTALL_HEADERS "Install header files" ON)

add_definitions(
    -DENABLE_MODULE_ECDH
    -DENABLE_MODULE_RECOVERY
    -DHAVE_CONFIG_H
)

file(GLOB SOURCES src/secp256k1.c)
add_library(secp256k1 ${SOURCES})

include_directories(${CMAKE_CURRENT_SOURCE_DIR})

install(TARGETS secp256k1
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

if(INSTALL_HEADERS)
    file(GLOB HEADERS include/*.h)
    install(FILES ${HEADERS} DESTINATION include)
endif()