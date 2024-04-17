﻿# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/metaparse
    REF boost-${VERSION}
    SHA512 9d0bb44bb83fdf8406745fa35af6e3d817197495629937dc747c1e3c3933bcc56ef669bec2685691925e5d1731bc8e1b1322cc7038757ea4bb126b207c47be52
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
