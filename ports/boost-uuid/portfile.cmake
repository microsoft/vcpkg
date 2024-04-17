﻿# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/uuid
    REF boost-${VERSION}
    SHA512 99f3f5094dce8258800db4d5d267f5f9a6df503e548b7700e0ede5131a04e8393c30a161d4b00d40ed0a3776802968282a1d20e076f9f3d385bc5a5f62f69618
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
