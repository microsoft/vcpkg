# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/outcome
    REF boost-1.74.0
    SHA512 115ff98875bd95d85f90c25f45617f3491803b627d028eb8d5669e17fe0438817a21be915b1f5a5bd46ad902b00acf5801d54572dad46b8982febf20d82f1110
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
