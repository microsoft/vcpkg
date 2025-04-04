# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/optional
    REF boost-${VERSION}
    SHA512 b552f006ad48cb9d60ddc7a2b7f2177aa5971a50f7939b097fa9c5f9fccb11ff68dc160ff2e675d0d615d2be08ea3c1f8a9e6342ad3bce81934510e97a67a94a
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
