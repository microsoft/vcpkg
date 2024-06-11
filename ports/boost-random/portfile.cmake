# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/random
    REF boost-${VERSION}
    SHA512 689829c7f00f9fedc7d87d9a23423d95f5ef96121d0d390de22534c95cbf380d299b0f735ab5d2de9cde4af93bb872e1284175461427b55b6307d3db8935ff09
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
