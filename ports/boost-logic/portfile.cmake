# Automatically generated by boost-vcpkg-helpers/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/logic
    REF boost-1.73.0
    SHA512 2ef43bbd47f105d1eb6542838777fd66925d82a98475da2b10c967779cc621cbe75f1432cab55fd713e99b7c01ce3dfe483b97f1b91b016e4d491a3f094ff6ae
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
