# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/lambda
    REF boost-${VERSION}
    SHA512 ae27369563fff55dc8a10aec2ae174850b010a36e8051ba00b87c98dd73c85c8f9488b9eeb965b28e6f4688034ed4d95b2bcd2bd0ca270fe9a3434c9a9d07502
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
