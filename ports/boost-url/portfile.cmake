# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/url
    REF boost-${VERSION}
    SHA512 939361058f294bfdba5bea510589a71f4c64bad785750a33fe7001d93bff966377ca032d9295370ed14476ff603ce7500d2d60f5eaf517d7d1e10ea3d1402ba1
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
