# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/poly_collection
    REF boost-1.74.0
    SHA512 fc9bc50f30eb6f7e7e044a0760ad3deea587338f4e86a09707d5f68459f3d55a9865726f6aed804c26c78f03040c6107d355a5984d2738010e7e233f960fb00b
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
