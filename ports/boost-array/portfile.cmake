﻿# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/array
    REF boost-${VERSION}
    SHA512 12c173e26e124d910da5905551855a3d4096bfb005b36cca799de5f7fc8cc0151b05a6e275fcfc7e3d4e80f77e55e1b1712081752e1eb4efdf55af5bd095253f
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
