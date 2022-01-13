# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/xpressive
    REF boost-1.78.0
    SHA512 9d9235e29d6ed07ab3ed88aedc8736093c93fad3507360fb506c7ed6cb5e9cdf115d6a2ebf5a1c5022189329b172b79e5dc64d63b6a0edea94c25820d3c138d9
    HEAD_REF master
)

if(NOT DEFINED CURRENT_HOST_INSTALLED_DIR)
    message(FATAL_ERROR "boost-xpressive requires a newer version of vcpkg in order to build.")
endif()

include(${CURRENT_HOST_INSTALLED_DIR}/share/vcpkg-boost-copy/vcpkg_boost_copy_headers.cmake)
vcpkg_boost_copy_headers(SOURCE_PATH ${SOURCE_PATH})
