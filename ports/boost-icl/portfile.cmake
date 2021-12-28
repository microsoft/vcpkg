# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/icl
    REF boost-1.77.0
    SHA512 680119595e9743b70a0444ee65cace053269d6c04133c1a59e82cf2e41f7e73b4aab160a232902cbbc5c2d5f7f6633c1f00e1564c8c62b95beafd247ff482399
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
