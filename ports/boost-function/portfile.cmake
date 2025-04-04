# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/function
    REF boost-${VERSION}
    SHA512 c4356fb9f04b1a2fbb141542fccdde5c9847a404f87cd18b903a6f2d5eccae0491e93db950df33e6ab20de0cba3bf0e42225e9eeed4b9b4718eba7cc93a56dfe
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
