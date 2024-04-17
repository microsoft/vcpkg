﻿# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/outcome
    REF boost-${VERSION}
    SHA512 8d25164f604d12d0c37b99133c616e7884c5c2c610d52e22b86fe642404ff1c97db026f17cd53426025c0d62405be7758d2764c13dfd28d344393ffebc82e3f6
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
