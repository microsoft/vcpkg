# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/compatibility
    REF boost-1.77.0
    SHA512 427d8c3f8fad551942b5003aefeea805ffd1a6bea7b6d9ad834e8814474b7168ac9040675c59fa4808d3389ac436a90d508dbbe0576dbb4b4b16bd479dd96538
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
