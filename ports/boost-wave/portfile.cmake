# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/wave
    REF boost-${VERSION}
    SHA512 18886d35565e3f0fce0c0756b9c5d79a842fb391b65aab9dd698b1c93231c128df3ffc3b16f5f6f32fba8d46e280a2046465072a33e850ae79fc92b756923d9a
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
