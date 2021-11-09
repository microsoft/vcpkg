# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/preprocessor
    REF boost-1.77.0
    SHA512 26d7487d9978551596cd243172c9ac6effd3f030244026fb73cac4dc64a458b5d1f0383ff4ac695492c598629d1bc93c186169b5be655d3cf700cf599cb22610
    HEAD_REF master
)

include(${CURRENT_INSTALLED_DIR}/share/boost-vcpkg-helpers/boost-modular-headers.cmake)
boost_modular_headers(SOURCE_PATH ${SOURCE_PATH})
