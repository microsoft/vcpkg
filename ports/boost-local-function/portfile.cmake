# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/local_function
    REF boost-${VERSION}
    SHA512 68dec23a37e8594883aca078d0f1bda607234491f91ac234077317ff161386465e49c3d3c9dec3a29b8d18296ed46c456270cabf12d945556c53020f238492b7
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
