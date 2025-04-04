# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/uuid
    REF boost-${VERSION}
    SHA512 2444a4ccf264ba304ba3609e8a06f19299b46c96564311b9ff3e0ed32a7153e6e630d00629e49df14aa5dfc4bf538642f1685518a65e9313e246d6970527a913
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
