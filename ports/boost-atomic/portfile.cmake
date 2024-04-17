﻿# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/atomic
    REF boost-${VERSION}
    SHA512 5a9045093fa51a22edcd61bb96ed2c1e62a5a397f8bfeff1b831a3f5ba19fe4b691ee738d43b2258b4c2d15b997ad9ea23cfb2248aa3e8e4d7189f9be86edc1a
    HEAD_REF master
)

file(READ "${SOURCE_PATH}/build/Jamfile.v2" _contents)
string(REPLACE "import config : requires" "import ../config/checks/config : requires" _contents "${_contents}")
string(REPLACE "project.load [ path.join [ path.make $(here:D) ] ../../config/checks/architecture ]" "project.load [ path.join [ path.make $(here:D) ] ../config/checks/architecture ]" _contents "${_contents}")
file(WRITE "${SOURCE_PATH}/build/Jamfile.v2" "${_contents}")
file(COPY "${CURRENT_INSTALLED_DIR}/share/boost-config/checks" DESTINATION "${SOURCE_PATH}/config")
include(${CURRENT_HOST_INSTALLED_DIR}/share/boost-build/boost-modular-build.cmake)
boost_modular_build(SOURCE_PATH ${SOURCE_PATH})
include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
# has_synchronization_lib.cpp is used in boost-modular-build-helper/Jamroot.jam.in
file(COPY "${SOURCE_PATH}/config/has_synchronization_lib.cpp" DESTINATION "${CURRENT_PACKAGES_DIR}/share/boost-atomic")
