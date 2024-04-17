﻿# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/endian
    REF boost-${VERSION}
    SHA512 660a44a73d551968620a39daad9b626827ab7dd3134bb1bcf6c2d24482f4db3b32f6b72159f4e98f9834ebc7c099454c6048082c7c05a4e3e0432c84928298db
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
