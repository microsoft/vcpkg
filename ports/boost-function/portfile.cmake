﻿# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/function
    REF boost-${VERSION}
    SHA512 20f4a4f8db929ba87d5061a32c610948e6eaf83c238f5b789828447741bf286ae6cd63c05a07d4b1b1ba83749ef978ea3b0e01e9c1534203c894f8f5438d7ae7
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
