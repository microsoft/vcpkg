# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/icl
    REF boost-${VERSION}
    SHA512 ae8142ae007cd076f8bcde0d1cd21f57d8405d8de8d996d59724c73fd9032ed881e089357e6111ccc6876e422a06aea1d48619a3353e076761efaaa8d8ed9616
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
