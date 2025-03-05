# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/convert
    REF boost-${VERSION}
    SHA512 068703f8f5cb053d0ab2bee06b3c8faed2847270268bbd8a25b189c99842152dbc2813f58ea8cb8da0bf1b7feba1591fcf217fc867fcac42e053025878821141
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
