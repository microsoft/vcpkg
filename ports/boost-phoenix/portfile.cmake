# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/phoenix
    REF boost-1.78.0
    SHA512 38d64222a205f76f94ca6822c9f67c41fad7001b0939548fdd725588cd0f95c0acbff64eb8ca93ca3184328d54d4b312bbf768237010ca20dff17c455589a9fc
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
