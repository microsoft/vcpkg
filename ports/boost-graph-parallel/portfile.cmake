﻿# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/graph_parallel
    REF boost-${VERSION}
    SHA512 bd8a88ba1b1b050623439fcd7d0910418b83add8f47395a0ea35808e96fd0c5a71abec93f037263a439d08640501850100e8d51ea7cf0e2c271a9cc0373c46cb
    HEAD_REF master
)

include(${CURRENT_HOST_INSTALLED_DIR}/share/boost-build/boost-modular-build.cmake)
boost_modular_build(SOURCE_PATH ${SOURCE_PATH})
include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
