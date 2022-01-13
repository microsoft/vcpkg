# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/static_string
    REF boost-1.78.0
    SHA512 979d079e1b9749701200944f056747253dc0993f217b8dc7e4fb2c94c67d002037c465c0bdd1f939b24be5a51bbd4790f9d0d0e8c8da1d5bfa0349ba402aa953
    HEAD_REF master
)

if(NOT DEFINED CURRENT_HOST_INSTALLED_DIR)
    message(FATAL_ERROR "boost-static-string requires a newer version of vcpkg in order to build.")
endif()

include(${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-boost-copy/vcpkg_boost_copy_headers.cmake)
vcpkg_boost_copy_headers(SOURCE_PATH ${SOURCE_PATH})
