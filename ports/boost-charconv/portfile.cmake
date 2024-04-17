﻿# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/charconv
    REF boost-${VERSION}
    SHA512 9cfe701bf0b24d5c11e3eaeb6de3693cc69ad2d3c59365e2ac7b5546ead726c476478e05b419d15091d5ae132b280e2a323241d9a9cd74967a23b810d7bfe71d
    HEAD_REF master
)

vcpkg_replace_string("${SOURCE_PATH}/build/Jamfile"
    "import ../../config/checks/config"
    "import ../config/checks/config"
)
file(COPY "${CURRENT_INSTALLED_DIR}/share/boost-config/checks" DESTINATION "${SOURCE_PATH}/config")
include(${CURRENT_HOST_INSTALLED_DIR}/share/boost-build/boost-modular-build.cmake)
boost_modular_build(SOURCE_PATH ${SOURCE_PATH})
include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
