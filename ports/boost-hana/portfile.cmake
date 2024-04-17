﻿# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/hana
    REF boost-${VERSION}
    SHA512 addcbeb1427b1e85aed9fbb8084c0de9e0acab3d1fb721d4f7b6c20b00d875c4b5aa97b7493c06ebbe5eb6ffea3d66f2845283ede5eb46acc9576ca7a4615685
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
