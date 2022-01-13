# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/atomic
    REF boost-1.78.0
    SHA512 a6eba43c7038228fa7ce537b05429e263397bc914235d9ad9aa47badce5455f4905e15e5f1979c19088b47faca3091bd0dfcdb017290f796d34a36b682592345
    HEAD_REF master
    PATCHES 0001-fix-compilation-for-uwp.patch
)

file(READ "${SOURCE_PATH}/build/Jamfile.v2" _contents)
string(REPLACE
    "project.load [ path.join [ path.make $(here:D) ] ../../config/checks/architecture ]"
    "project.load [ path.join [ path.make $(here:D) ] ../config/checks/architecture ]"
    _contents "${_contents}")
file(WRITE "${SOURCE_PATH}/build/Jamfile.v2" "${_contents}")
file(COPY "${CURRENT_INSTALLED_DIR}/share/boost-config/checks" DESTINATION "${SOURCE_PATH}/config")
if(NOT DEFINED CURRENT_HOST_INSTALLED_DIR)
    message(FATAL_ERROR "boost-atomic requires a newer version of vcpkg in order to build.")
endif()

include(${CURRENT_HOST_INSTALLED_DIR}/share/boost-build/vcpkg_boost_build.cmake)
vcpkg_boost_build(SOURCE_PATH ${SOURCE_PATH})
include(${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-boost-copy/vcpkg_boost_copy_headers.cmake)
vcpkg_boost_copy_headers(SOURCE_PATH ${SOURCE_PATH})
