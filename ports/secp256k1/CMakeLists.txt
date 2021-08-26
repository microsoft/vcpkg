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

include_directories(${CMAKE_CURRENT_SOURCE_DIR}/src)

target_include_directories(secp256k1 PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> $<INSTALL_INTERFACE:include>)

if(INSTALL_HEADERS)
    file(GLOB HEADERS include/*.h)
    install(FILES ${HEADERS} DESTINATION include)
endif()

install(TARGETS secp256k1 EXPORT unofficial-secp256k1-targets
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

install(
    EXPORT unofficial-secp256k1-targets
    FILE unofficial-secp256k1-targets.cmake
    NAMESPACE unofficial::
    DESTINATION share/unofficial-secp256k1
)