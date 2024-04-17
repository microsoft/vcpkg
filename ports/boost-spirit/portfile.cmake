﻿# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/spirit
    REF boost-${VERSION}
    SHA512 224487a61197e869cafd8089eda6c977ab0c37feb02fa39b8a23c7e80393bacc215e4b42c7e9ab7189f744776717b3412dfd6ddf05a34111cc32d671de17b9f1
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
