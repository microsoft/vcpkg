# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/nowide
    REF boost-${VERSION}
    SHA512 460a79592a22653999ad189842b9eb984cf1a9c7418ac7b93f3f57b0192fa67b12c286cc439680a248ac7a7efeded1e44dfc95a8545b8e2a3a953bb4b9fd66b9
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
