# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/coroutine2
    REF boost-${VERSION}
    SHA512 55701687a22162d4c46489bae318c064de13140f7df9b7f239bea398e1d63f8a0894183ef28e9c645981adc6b9f7284bf69ca4d4ad8ffb9138c488fa49012408
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
