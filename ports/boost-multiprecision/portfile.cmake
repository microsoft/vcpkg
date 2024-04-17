﻿# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/multiprecision
    REF boost-${VERSION}
    SHA512 f53203f86bf282403c8f5c7a27fd2e277b3dafab4422d8ec6b4b2fb827ec4e8d0cf3572c1f6985a54714822ed8a384d1d29e840a0913a123f32a2f5e187cdef1
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
