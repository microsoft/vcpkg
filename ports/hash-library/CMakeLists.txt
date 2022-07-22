cmake_minimum_required(VERSION 3.5.1)
project(hash-library CXX)

set(HEADERS
    crc32.h
    hash.h
    hmac.h
    keccak.h
    md5.h
    sha1.h
    sha256.h
    sha3.h
)

set(SRCS
    crc32.cpp
    keccak.cpp
    md5.cpp
    sha1.cpp
    sha256.cpp
    sha3.cpp
)

add_library(hash-library ${SRCS})

target_include_directories(hash-library PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> $<INSTALL_INTERFACE:include/hash-library>)

if(NOT DISABLE_INSTALL_HEADERS)
    install(FILES ${HEADERS} DESTINATION include/hash-library)
endif()

install(
    TARGETS hash-library
    EXPORT unofficial-hash-library-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
)

install(
    EXPORT unofficial-hash-library-targets
    FILE unofficial-hash-library-targets.cmake
    NAMESPACE unofficial::
    DESTINATION share/unofficial-hash-library
)
