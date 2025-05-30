# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/hash2
    REF boost-${VERSION}
    SHA512 df427172395b5e0b141fb652282802f4258878d4d4ede7967498fca21213fe3ed78be5b6824b58176d8c81f91bc1c3030949b327b06e5bb554e2e0c34450225d
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
