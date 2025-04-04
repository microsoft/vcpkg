# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/redis
    REF boost-${VERSION}
    SHA512 dee4f861f2d2879fdad9eeb16d6123df815fd4845baaaee1d1495116f23013e4396955573f1aaa1cee1780c1b0a1e3201068da8c457fbac08eae97a95dabd988
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
