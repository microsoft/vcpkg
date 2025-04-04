# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/python
    REF boost-${VERSION}
    SHA512 0218378fda1782c88ebb6d44b8b6ac90e583ec16565bb0b6046365be63b001fc78853ddc449307e4265994c29681377c0b53428ce0a1203795105cc2e6902ce6
    HEAD_REF master
    PATCHES
        remove_undef.diff
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
