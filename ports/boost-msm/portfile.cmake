# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/msm
    REF boost-1.76.0
    SHA512 88734ef44bd8b8fe41920ed2e2d0576c87b86604fe8bb33e5512e01719593287028475bbd1a597ba4b8d32bc7cc119e2c62d9efc8006f772abce0fb988f8e9d1
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
