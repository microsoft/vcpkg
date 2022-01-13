# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/sort
    REF boost-1.78.0
    SHA512 4bb1626f58bfbd69bb0ae9d7844b5d1e3d5c55cc62e1ba0398d00775151704a3c2a83916ac166f3821ed96f7565f3bfd546af28157ab6a1b8ea64820550cad26
    HEAD_REF master
)

if(NOT DEFINED CURRENT_HOST_INSTALLED_DIR)
    message(FATAL_ERROR "boost-sort requires a newer version of vcpkg in order to build.")
endif()

include(${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-boost-copy/vcpkg_boost_copy_headers.cmake)
vcpkg_boost_copy_headers(SOURCE_PATH ${SOURCE_PATH})
