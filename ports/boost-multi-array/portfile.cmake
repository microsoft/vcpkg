# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/multi_array
    REF boost-${VERSION}
    SHA512 aa6857acebf1b9b06a3543fd70f94b90e027b16fdb81651dc18d82b006aff7a955331c051647d3041af79be023093237d8a8813bfa730002a35dc073c1b4f009
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
