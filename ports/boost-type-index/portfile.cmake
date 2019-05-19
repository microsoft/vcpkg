# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

include(vcpkg_common_functions)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/type_index
    REF boost-1.70.0
    SHA512 e7c6c36c4c24045fcb9ddd3a804b051b1076bab92488927b0fb5b6e9f551c45c19c09a33e4002e843fd00500e40dd7511ff23124f73fe889883f79e35fbb4bd3
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
