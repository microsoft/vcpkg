# Automatically generated by scripts/boost/generate-ports.ps1

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO boostorg/local_function
    REF boost-${VERSION}
    SHA512 895d0f31f2ea561aa5723e04090d4c192f66d1a03aae9cd5f1413a67aa9f88a87c5e44fd36b89f9624862a9c62ec74039d0bff5348080e8560300f369353e428
    HEAD_REF master
)

set(FEATURE_OPTIONS "")
boost_configure_and_install(
    SOURCE_PATH "${SOURCE_PATH}"
    OPTIONS ${FEATURE_OPTIONS}
)
