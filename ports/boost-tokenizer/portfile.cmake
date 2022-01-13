# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/tokenizer
    REF boost-1.78.0
    SHA512 e29fb1eedd967c3a1450fad55054a9b07f866f5202058c900b31923127b78eb7a4b7f433a14b9eb6dc5e9bbde8f4be17e940f08f5df200a2df73e0c2132325d5
    HEAD_REF master
)

if(NOT DEFINED CURRENT_HOST_INSTALLED_DIR)
    message(FATAL_ERROR "boost-tokenizer requires a newer version of vcpkg in order to build.")
endif()

include(${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-boost-copy/vcpkg_boost_copy_headers.cmake)
vcpkg_boost_copy_headers(SOURCE_PATH ${SOURCE_PATH})
