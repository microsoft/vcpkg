# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/integer
    REF boost-${VERSION}
    SHA512 d0b8eb5fd459cbb89be7cbb7a013fd0620193fd7c4bcf572de6871b602e3584b899e1643909f1d0f436dc03bb0765737a391c9ce5fb82f2c2c6116b01c52e459
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
