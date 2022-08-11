# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/python
    REF boost-1.79.0
    SHA512 de41d0eb76709c7aaeb2bf7a459c0c3a3372e0747e2261773569c27e8bf78baad158cfb3bc4316c3073b000665f6faf664bcd34a2f68c40382b9d3c935ce2c42
    HEAD_REF master
)

include(${CURRENT_HOST_INSTALLED_DIR}/share/boost-build/boost-modular-build.cmake)
boost_modular_build(SOURCE_PATH ${SOURCE_PATH})
include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
