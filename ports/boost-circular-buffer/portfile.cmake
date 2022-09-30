# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/circular_buffer
    REF boost-1.80.0
    SHA512 1d7cc56dbdc66ad9a3956ee02e351fe1efca8419fa8a2a6bda1fad4f23676cd29d66a92c7ecb73295edd7a8ed3180614923e233bc55c3f3dfc39be86a8118fe2
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
