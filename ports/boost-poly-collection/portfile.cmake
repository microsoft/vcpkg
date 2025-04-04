# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/poly_collection
    REF boost-${VERSION}
    SHA512 26fa1c9017c7bab84fd929e49cbea70e7dcf0c2080ed83ad655b0d8cae11764ffb0e9ebe29589bf1ad20e927b6ca3cc1288764041e8f983d18ea084f3554f1a6
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
