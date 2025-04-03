# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/ublas
    REF boost-${VERSION}
    SHA512 a1306d8f77c9a09fb18ad6a5bceaabe7afcaa5347ddd2f5777e4ce72127ac2d0939b103d1e09d0eefe547f00d33ca7234d4a2c838fe1258fe8f8510208f6008c
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
